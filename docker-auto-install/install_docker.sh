#!/usr/bin/env bash
set -Eeuo pipefail

add_user_to_group=true

usage() {
    cat <<'EOF'
Usage: install_docker.sh [--skip-group]

Install Docker Engine from Docker's official apt repository on Debian or Ubuntu.

Options:
  --skip-group  Do not add the invoking user to the docker group.
  -h, --help    Show this help text.
EOF
}

while (($#)); do
    case "$1" in
        --skip-group)
            add_user_to_group=false
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

trap 'echo "Docker installation failed near line $LINENO." >&2' ERR

if [[ ! -r /etc/os-release ]]; then
    echo "Cannot identify the operating system: /etc/os-release is unavailable." >&2
    exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release

case "${ID:-}" in
    debian|ubuntu)
        docker_distribution=$ID
        ;;
    *)
        echo "Unsupported distribution: ${PRETTY_NAME:-${ID:-unknown}}" >&2
        echo "This installer supports Docker-supported Debian and Ubuntu releases." >&2
        exit 1
        ;;
esac

codename=${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}
if [[ -z "$codename" ]]; then
    echo "Could not determine the distribution codename from /etc/os-release." >&2
    exit 1
fi

for command in apt-get dpkg install; do
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

invoking_user=${SUDO_USER:-${USER:-}}
architecture=$(dpkg --print-architecture)
key_tmp=$(mktemp)
trap 'rm -f "$key_tmp"' EXIT

echo "Installing prerequisites..."
"${sudo_cmd[@]}" apt-get update
"${sudo_cmd[@]}" apt-get install -y ca-certificates curl

echo "Installing Docker's signing key..."
"${sudo_cmd[@]}" install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/${docker_distribution}/gpg" -o "$key_tmp"
"${sudo_cmd[@]}" install -m 0644 "$key_tmp" /etc/apt/keyrings/docker.asc

echo "Configuring Docker's apt repository..."
cat <<EOF | "${sudo_cmd[@]}" tee /etc/apt/sources.list.d/docker.sources >/dev/null
Types: deb
URIs: https://download.docker.com/linux/${docker_distribution}
Suites: ${codename}
Components: stable
Architectures: ${architecture}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

"${sudo_cmd[@]}" apt-get update
"${sudo_cmd[@]}" apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

if command -v systemctl >/dev/null 2>&1; then
    echo "Enabling and starting Docker..."
    "${sudo_cmd[@]}" systemctl enable --now docker
fi

docker --version
docker compose version

if [[ "$add_user_to_group" == true ]]; then
    if [[ -n "$invoking_user" && "$invoking_user" != root ]]; then
        echo "Adding $invoking_user to the docker group..."
        echo "Warning: docker group membership grants root-equivalent host access."
        "${sudo_cmd[@]}" usermod -aG docker "$invoking_user"
        echo "Log out and back in before running Docker without sudo."
    else
        echo "No non-root invoking user was detected; skipping docker group membership."
    fi
else
    echo "Skipping docker group membership as requested."
fi

echo "Docker Engine installation completed successfully."
