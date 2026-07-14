# Docker Installation Script for Debian

This script automates the installation of Docker Engine on Debian systems using Docker's official apt repository. It sets up the repository with the current recommended method (keyring in `/etc/apt/keyrings`), installs Docker along with the Buildx and Compose plugins, and adds the current user to the `docker` group.

## Overview

The script performs the following actions:

1. Updates the package database.
2. Installs prerequisite packages (`ca-certificates`, `curl`).
3. Adds Docker's official GPG key to `/etc/apt/keyrings/docker.asc`.
4. Sets up the Docker apt repository for your Debian release (detected via `/etc/os-release`).
5. Updates the package database with Docker packages.
6. Installs Docker (`docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`).
7. Verifies the Docker installation.
8. Adds the current user to the `docker` group for managing Docker as a non-root user.

## Prerequisites

- A Debian system (Debian 12 "bookworm" or newer) with internet access.
- Sudo privileges for the executing user.

## Usage

1. **Download the Script:**
   Download the `install_docker.sh` script to your Debian system.

2. **Make the Script Executable:**

   ```
   chmod +x install_docker.sh
   ```

3. **Run the Script** (as your normal user, not as root — the script uses `sudo` where needed):

   ```
   ./install_docker.sh
   ```

   The script will ask for the sudo password if required.

## Notes

- The script automatically answers 'yes' to all prompts (`-y` flag with `apt-get`).
- The script includes checks after each critical step. If any step fails, the script will terminate and an error message will be displayed.
- After installation, log out and log back in (or reboot) so the `docker` group membership takes effect and you can run `docker` without sudo.
- Adding a user to the `docker` group grants root-equivalent access to the host — only do this for trusted users.

## Disclaimer

This script is provided "as is", without warranty of any kind. Use it at your own risk.
