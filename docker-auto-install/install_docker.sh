#!/bin/bash

set -o pipefail

# Function to check if a command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed to execute."
        exit 1
    fi
}

# Update the package database
echo "Updating package database..."
sudo apt-get update
check_success "Package database update"

# Install prerequisite packages
echo "Installing prerequisite packages..."
sudo apt-get install -y ca-certificates curl
check_success "Prerequisite package installation"

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
check_success "GPG key addition"
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Set up the Docker repository
echo "Setting up the Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
check_success "Docker repository setup"

# Update the package database with Docker packages
echo "Updating package database with Docker packages..."
sudo apt-get update
check_success "Package database update with Docker packages"

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
check_success "Docker installation"

# Verify Docker installation
echo "Verifying Docker installation..."
docker --version
check_success "Docker verification"

# Add the current user to the Docker group (optional)
echo "Adding current user to the Docker group..."
sudo usermod -aG docker "${USER}"
check_success "User addition to Docker group"

echo "Docker installation and setup completed successfully."
echo "Log out and back in (or reboot) for the docker group change to take effect."
