# Plex Media Server Installation Script for Debian

This script downloads and installs the latest Plex Media Server release on a Debian (x86_64) system, then enables and starts the service.

## What the Script Does

1. Installs `curl` and `jq` if needed.
2. Queries Plex's official download API (`plex.tv/api/downloads/5.json`) for the latest Debian x86_64 package URL.
3. Downloads the `.deb` package to a temporary file.
4. Installs the package (resolving dependencies if necessary) and cleans up the download.
5. Enables and starts the `plexmediaserver` systemd service.
6. Shows the service status.

## Prerequisites

- A Debian-based x86_64 system with internet access.
- Sudo privileges for the executing user.

## Usage

```
chmod +x install_plex.sh
./install_plex.sh
```

After installation, open a browser and finish setup at:

```
http://<Your-Server-IP>:32400/web
```

## Notes

- The script always installs the latest **public** release. Plex Pass beta builds require a Plex Pass token and are not handled by this script.
- Re-running the script upgrades an existing installation to the latest version.

## Disclaimer

This script is provided "as is", without warranty of any kind. Use it at your own risk.
