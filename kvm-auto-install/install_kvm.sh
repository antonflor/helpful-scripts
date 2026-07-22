#!/usr/bin/env bash
set -Eeuo pipefail

with_gui=false
skip_groups=false

usage() {
    cat <<'EOF'
Usage: install_kvm.sh [options]

Install a KVM/QEMU and libvirt host on Debian or Ubuntu.

Options:
  --with-gui     Install virt-manager and virt-viewer.
  --skip-groups  Do not add the invoking user to libvirt and kvm groups.
  -h, --help     Show this help text.
EOF
}

while (($#)); do
    case "$1" in
        --with-gui)
            with_gui=true
            shift
            ;;
        --skip-groups)
            skip_groups=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

trap 'echo "KVM installation failed near line $LINENO." >&2' ERR

if [[ ! -r /etc/os-release ]]; then
    echo "/etc/os-release is unavailable; cannot identify the distribution." >&2
    exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
case "${ID:-}" in
    debian|ubuntu) ;;
    *)
        echo "Unsupported distribution: ${PRETTY_NAME:-${ID:-unknown}}" >&2
        echo "This installer supports Debian and Ubuntu." >&2
        exit 1
        ;;
esac

for command in apt-get dpkg systemctl virsh; do
    if [[ "$command" == virsh ]]; then
        continue
    fi
    command -v "$command" >/dev/null 2>&1 || {
        echo "Required command not found: $command" >&2
        exit 1
    }
done

if ((EUID == 0)); then
    sudo_cmd=()
else
    command -v sudo >/dev/null 2>&1 || {
        echo "sudo is required when the script is not run as root." >&2
        exit 1
    }
    sudo_cmd=(sudo)
fi

architecture=$(dpkg --print-architecture)
case "$architecture" in
    amd64)
        qemu_package=qemu-system-x86
        if ! grep -Eq '(^|[[:space:]])(vmx|svm)([[:space:]]|$)' /proc/cpuinfo && [[ ! -e /dev/kvm ]]; then
            echo "Hardware virtualization is unavailable. Enable Intel VT-x/AMD-V in firmware or expose virtualization to this guest." >&2
            exit 1
        fi
        ;;
    arm64)
        qemu_package=qemu-system-arm
        if [[ ! -e /dev/kvm ]]; then
            echo "/dev/kvm is unavailable; hardware virtualization is not exposed to this system." >&2
            exit 1
        fi
        ;;
    *)
        echo "Unsupported architecture: $architecture" >&2
        exit 1
        ;;
esac

packages=(
    "$qemu_package"
    qemu-utils
    libvirt-daemon-system
    libvirt-clients
    bridge-utils
)

if [[ "$with_gui" == true ]]; then
    packages+=(virt-manager virt-viewer)
fi

echo "Installing KVM/QEMU and libvirt packages..."
"${sudo_cmd[@]}" apt-get update
"${sudo_cmd[@]}" apt-get install -y "${packages[@]}"

service_started=false
for service in libvirtd.service virtqemud.service; do
    if systemctl list-unit-files "$service" --no-legend 2>/dev/null | grep -q "^$service"; then
        echo "Enabling and starting $service..."
        "${sudo_cmd[@]}" systemctl enable --now "$service"
        service_started=true
        break
    fi
done

if [[ "$service_started" != true ]]; then
    echo "No supported libvirt service unit was found after installation." >&2
    exit 1
fi

invoking_user=${SUDO_USER:-${USER:-}}
if [[ "$skip_groups" != true && -n "$invoking_user" && "$invoking_user" != root ]]; then
    for group in libvirt kvm; do
        if getent group "$group" >/dev/null 2>&1; then
            echo "Adding $invoking_user to $group..."
            "${sudo_cmd[@]}" usermod -aG "$group" "$invoking_user"
        fi
    done
    echo "Log out and back in before using libvirt without sudo."
fi

if [[ -e /dev/kvm ]]; then
    echo "KVM device:"
    ls -l /dev/kvm
else
    echo "Warning: /dev/kvm is still unavailable after package installation." >&2
fi

echo "Validating the system libvirt connection..."
"${sudo_cmd[@]}" virsh -c qemu:///system list --all

echo "KVM/libvirt installation completed successfully."
