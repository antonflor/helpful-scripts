#!/bin/bash

set -o pipefail

# Update and install necessary packages
sudo apt-get update
sudo apt-get install -y curl jq

# Fetch the latest Plex Media Server URL for Debian
echo "Looking up the latest Plex Media Server release..."
PLEX_JSON=$(curl -fsSL https://plex.tv/api/downloads/5.json)
PLEX_URL=$(echo "$PLEX_JSON" | jq -r '.computer.Linux.releases[] | select(.build=="linux-x86_64") | select(.distro=="debian") | .url')

if [ -z "$PLEX_URL" ] || [ "$PLEX_URL" = "null" ]; then
    echo "Error: could not determine the Plex download URL." 1>&2
    exit 1
fi

# Download the latest Plex Media Server package
DEB_FILE=$(mktemp /tmp/plexmediaserver.XXXXXX.deb)
echo "Downloading Plex Media Server..."
curl -fSL "$PLEX_URL" --output "$DEB_FILE"

# Install Plex Media Server
echo "Installing Plex Media Server..."
sudo dpkg -i "$DEB_FILE" || sudo apt-get -f install -y
rm -f "$DEB_FILE"

# Enable and start Plex Media Server
echo "Enabling and starting Plex Media Server..."
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver

# Check the status of Plex Media Server
echo "Checking the status of Plex Media Server..."
sudo systemctl status plexmediaserver --no-pager

echo "Installation complete. You can access Plex at http://<Your-Server-IP>:32400/web"
