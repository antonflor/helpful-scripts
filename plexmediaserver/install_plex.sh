#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "Plex Media Server installation failed near line $LINENO." >&2' ERR

if [[ ! -r /etc/os-release ]]; then
    echo "/etc/os-release is unavailable; cannot identify the distribution." >&2
    exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != debian && "${ID:-}" != ubuntu && " ${ID_LIKE:-} " != *" debian "* ]]; then
    echo "Unsupported distribution: ${PRETTY_NAME:-${ID:-unknown}}" >&2
    echo "This installer supports Debian-based systems with apt." >&2
    exit 1
fi

for command in apt-get install gpg; do
    if [[ "$command" == gpg ]]; then
        continue
    fi
    command -v "$command" >/dev/null 2>&1 || {
        echo "Required command not found: $command" >&2
        exit 1
    }
done

if ((EUID == 0)); then
    sudo_cmd=()
else
    command -v sudo >/dev/null 2>&1 || {
        echo "sudo is required when the script is not run as root." >&2
        exit 1
    }
    sudo_cmd=(sudo)
fi

key_source=$(mktemp)
key_binary=$(mktemp)
trap 'rm -f "$key_source" "$key_binary"' EXIT

echo "Installing repository prerequisites..."
"${sudo_cmd[@]}" apt-get update
"${sudo_cmd[@]}" apt-get install -y ca-certificates curl gnupg

echo "Installing Plex's v2 repository signing key..."
curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.v2.key -o "$key_source"
gpg --batch --yes --dearmor --output "$key_binary" "$key_source"
"${sudo_cmd[@]}" install -m 0755 -d /etc/apt/keyrings
"${sudo_cmd[@]}" install -m 0644 "$key_binary" /etc/apt/keyrings/plexmediaserver.v2.gpg

echo "Removing superseded Plex apt source files..."
"${sudo_cmd[@]}" find /etc/apt/sources.list.d -maxdepth 1 -type f \
    \( -name 'plex*.list' -o -name 'plex*.sources' \) -delete

echo "Configuring Plex's official apt repository..."
echo "deb [signed-by=/etc/apt/keyrings/plexmediaserver.v2.gpg] https://repo.plex.tv/deb/ public main" |
    "${sudo_cmd[@]}" tee /etc/apt/sources.list.d/plex.list >/dev/null

"${sudo_cmd[@]}" apt-get update
"${sudo_cmd[@]}" apt-get install -y plexmediaserver

if command -v systemctl >/dev/null 2>&1; then
    echo "Enabling and starting Plex Media Server..."
    "${sudo_cmd[@]}" systemctl enable --now plexmediaserver
    "${sudo_cmd[@]}" systemctl is-active --quiet plexmediaserver
fi

server_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
server_ip=${server_ip:-127.0.0.1}

echo "Plex Media Server installation completed successfully."
echo "Open http://${server_ip}:32400/web to finish setup."
echo "The plex service account must have read and execute access to your media paths."
