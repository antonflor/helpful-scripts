# Docker Engine Installer for Debian and Ubuntu

This script installs Docker Engine, containerd, Buildx, and the Docker Compose plugin from Docker's official apt repository.

## Behavior

- Supports Docker-supported Debian and Ubuntu releases.
- Detects the distribution, release codename, and package architecture.
- Uses the modern deb822 `.sources` repository format and a dedicated apt keyring.
- Can be rerun safely to repair or upgrade the installation.
- Enables and starts Docker when `systemd` is available.
- Adds the invoking non-root user to the `docker` group unless `--skip-group` is supplied.

## Requirements

- Debian or Ubuntu with internet access
- `apt-get` and `dpkg`
- Root access or `sudo`

Derivatives are intentionally rejected because their release codenames may not map cleanly to Docker's repositories.

## Usage

```bash
chmod +x install_docker.sh
./install_docker.sh
```

Skip docker group membership:

```bash
./install_docker.sh --skip-group
```

Run `./install_docker.sh --help` for the option summary.

## Security note

Membership in the `docker` group grants root-equivalent control of the host. Use `--skip-group` on shared systems or whenever users should run Docker through `sudo` instead.

## Validation

After installation, the script prints the installed Docker Engine and Compose versions. After logging out and back in, a trusted docker-group member can test the daemon with:

```bash
docker run --rm hello-world
```
