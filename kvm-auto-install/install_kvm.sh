#!/bin/bash

# Check for CPU virtualization support
if egrep -c '(vmx|svm)' /proc/cpuinfo > 0; then
    echo "Installer can continue: CPU supports virtualization."
else
    echo "CPU does not support virtualization. Exiting."
    exit 1
fi

# Update packages and install KVM and related tools
echo "Installing KVM and related tools..."
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager virt-viewer cpu-checker

# Add the current user to the libvirt group
echo "Adding $(whoami) to the libvirt group..."
sudo usermod -aG libvirt $(whoami)

# Inform the user
echo "User $(whoami) added to libvirt group."

# Check KVM status
echo "Checking KVM status with kvm-ok..."
kvm-ok

# Check libvirtd service status
echo "Checking libvirtd service status..."
serviceStatus=$(sudo systemctl status libvirtd | grep "Active:")

echo $serviceStatus

# Check if libvirtd is active and running
if [[ $serviceStatus == *"active (running)"* ]]; then
    echo "libvirtd is active and running."
else
    echo "libvirtd is not running. Please check the service status."
fi
