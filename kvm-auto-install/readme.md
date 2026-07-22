# KVM/QEMU and libvirt Installer

This script prepares a Debian or Ubuntu host for hardware-accelerated virtualization with KVM, QEMU, and libvirt.

## Behavior

- Checks that hardware virtualization is exposed before installing packages.
- Supports `amd64` and `arm64` package selections.
- Installs a headless virtualization stack by default.
- Optionally installs `virt-manager` and `virt-viewer`.
- Starts either `libvirtd.service` or the modular `virtqemud.service`, depending on the distribution.
- Adds the invoking non-root user to available `libvirt` and `kvm` groups unless disabled.
- Validates the system libvirt connection with `virsh`.

## Requirements

- Debian or Ubuntu
- Intel VT-x, AMD-V, or ARM virtualization support exposed by the kernel/hypervisor
- Root access or `sudo`
- `systemd`

When running inside a virtual machine, the outer hypervisor must expose nested virtualization.

## Usage

Install the headless stack:

```bash
chmod +x install_kvm.sh
./install_kvm.sh
```

Include desktop management tools:

```bash
./install_kvm.sh --with-gui
```

Skip user group changes:

```bash
./install_kvm.sh --skip-groups
```

After group membership changes, log out and back in before using `virsh` as a non-root user.

## Validation

Useful follow-up commands:

```bash
virsh -c qemu:///system list --all
systemctl status libvirtd --no-pager
systemctl status virtqemud --no-pager
```

Only one of the two service units may exist on a given system.
