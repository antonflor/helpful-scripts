# KVM Installation Script

This repository contains a script for setting up a KVM (Kernel-based Virtual Machine) environment on a Debian-based system. It checks for CPU virtualization support, installs necessary packages, adds the user to the `libvirt` group, and verifies the installation.

## Prerequisites
- A Debian-based Linux distribution.
- A CPU that supports hardware virtualization (Intel VT-x or AMD-V).
- Sudo privileges on the system.

## Installation
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/kvm-install-script.git
   cd kvm-install-script
   ```
2. **Make the Script Executable**:
   ```bash
   chmod +x kvm_install.sh
   ```
3. **Run the Script**:
   ```bash
   ./kvm_install.sh
   ```
   Follow the on-screen instructions. The script will ask for your sudo password.

## What the Script Does
1. Checks if your CPU supports virtualization.
2. Installs KVM, QEMU, and other necessary tools.
3. Adds your user to the `libvirt` group.
4. Checks the status of the `libvirtd` service.

## Post-Installation
- You may need to log out and log back in for the group changes to take effect.
- Run `kvm-ok` to verify that KVM is set up correctly.
- Use `virsh` or `virt-manager` to manage your virtual machines.

## Troubleshooting
If you encounter issues, check the following:
- Ensure your CPU supports hardware virtualization.
- Verify that you have sudo privileges.
- Check the `libvirtd` service status if the script indicates it's not running.

## Contributing
Contributions to improve the script or documentation are welcome. Please submit a pull request or open an issue if you have suggestions or find a bug.

## License
This project is open-source and available under the [MIT License](LICENSE).
