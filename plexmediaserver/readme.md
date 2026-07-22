# Plex Media Server Installer for Debian-Based Systems

This script configures Plex's official apt repository and installs Plex Media Server on Debian, Ubuntu, and compatible Debian-based systems.

## Why it uses the apt repository

Plex changed its Linux repositories beginning with Plex Media Server 1.43.0. The installer uses the current v2 signing key and official repository so future public releases can be installed through normal `apt update` and `apt upgrade` workflows.

## What the script does

1. Installs `ca-certificates`, `curl`, and `gnupg`.
2. Downloads and installs Plex's v2 repository signing key.
3. Removes superseded Plex source-list files.
4. Configures `https://repo.plex.tv/deb/` with a dedicated keyring.
5. Installs or upgrades the `plexmediaserver` package.
6. Enables and starts the systemd service when available.
7. Prints a local Plex Web setup URL.

## Requirements

- A Debian-based system with `apt`
- Internet access
- Root access or `sudo`

## Usage

```bash
chmod +x install_plex.sh
./install_plex.sh
```

After installation, open the URL printed by the script or browse locally to:

```text
http://127.0.0.1:32400/web
```

## Media permissions

Plex Media Server runs as the `plex` service account by default. The account needs read permission on media files and read/execute permission on every parent directory in the path. Do not solve permission problems by making an entire media tree world-writable.

## Updates

Once the repository is configured, update Plex with the normal package workflow:

```bash
sudo apt update
sudo apt upgrade
```

This installs public releases from the Plex repository. Plex Pass beta-channel selection is outside this script's scope.
