#!/bin/bash

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
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
check_success "Prerequisite package installation"

# Add Docker’s official GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
check_success "GPG key addition"

# Set up the Docker repository
echo "Setting up the Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
check_success "Docker repository setup"

# Update the package database with Docker packages
echo "Updating package database with Docker packages..."
sudo apt-get update
check_success "Package database update with Docker packages"

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
check_success "Docker installation"

# Verify Docker installation
echo "Verifying Docker installation..."
docker --version
check_success "Docker verification"

# Add the current user to the Docker group (optional)
echo "Adding current user to the Docker group..."
sudo usermod -aG docker ${USER}
check_success "User addition to Docker group"

echo "Docker installation and setup completed successfully."
