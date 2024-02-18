# Docker Installation Script for Debian 12

This script automates the installation of Docker on Debian 12 systems. It includes downloading and setting up Docker, adding the necessary GPG keys and repositories, and ensuring that the current user is added to the Docker group.

## Overview

The script performs the following actions:

1. Updates the package database.
2. Installs prerequisite packages necessary for Docker installation.
3. Adds Docker’s official GPG key.
4. Sets up the Docker repository.
5. Updates the package database with Docker packages.
6. Installs Docker (including `docker-ce`, `docker-ce-cli`, and `containerd.io`).
7. Verifies the Docker installation.
8. Adds the current user to the Docker group for managing Docker as a non-root user.

## Prerequisites

- A Debian 12 system with internet access.
- Sudo privileges for the executing user.

## Usage

1. **Download the Script:**
   Download the `install_docker.sh` script to your Debian 12 system.

2. **Make the Script Executable:**
   Change the script's permissions to make it executable:

   ```
   chmod +x install_docker.sh
   ```
Run the Script:
Execute the script:

```
./install_docker.sh
```
The script will ask for the sudo password if required.

Notes
The script needs to be run with sudo privileges to install packages and make system configurations.
It automatically answers 'yes' to all prompts (-y flag with apt-get).
The script includes checks after each critical step. If any step fails, the script will terminate, and an error message will be displayed.
After installation, it's recommended to log out and log back in or reboot the system to ensure that group changes take effect and Docker runs smoothly.
Disclaimer
This script is provided "as is", without warranty of any kind. Use it at your own risk.




### Instructions for Creating the README.md File

1. Open a text editor and paste the above content into it.
2. Save the file with the name `README.md` in the same directory as your `install_docker.sh` script.
3. You can view this file with any Markdown viewer, or on platforms like GitHub or GitLab, which render Markdown files automatically.
