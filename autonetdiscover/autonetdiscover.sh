#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
    cat <<'EOF'
Usage: autonetdiscover.sh [--interface NAME --subnet CIDR]

Interactively select a local interface/subnet pair and scan it with arp-scan.
Both --interface and --subnet must be supplied together for non-interactive use.
EOF
}

interface=""
subnet=""

while (($#)); do
    case "$1" in
        -i|--interface)
            [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
            interface=$2
            shift 2
            ;;
        -s|--subnet)
            [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
            subnet=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

for command in ip arp-scan; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Required command not found: $command" >&2
        exit 1
    fi
done

if ((EUID != 0)); then
    echo "arp-scan requires root privileges. Run this script with sudo." >&2
    exit 1
fi

mapfile -t network_pairs < <(
    ip -o -4 addr show up scope global |
        awk '{print $2 "|" $4}' |
        sort -u
)

if ((${#network_pairs[@]} == 0)); then
    echo "No active, globally scoped IPv4 interfaces were found." >&2
    exit 1
fi

if [[ -n "$interface" || -n "$subnet" ]]; then
    if [[ -z "$interface" || -z "$subnet" ]]; then
        echo "--interface and --subnet must be supplied together." >&2
        exit 2
    fi

    requested_pair="$interface|$subnet"
    pair_found=false
    for pair in "${network_pairs[@]}"; do
        if [[ "$pair" == "$requested_pair" ]]; then
            pair_found=true
            break
        fi
    done

    if [[ "$pair_found" != true ]]; then
        echo "$subnet is not assigned to active interface $interface." >&2
        exit 2
    fi
else
    echo "Available interface/subnet pairs:"
    PS3="Select a network to scan: "
    select selected_pair in "${network_pairs[@]}"; do
        if [[ -n "$selected_pair" ]]; then
            IFS='|' read -r interface subnet <<<"$selected_pair"
            break
        fi
        echo "Invalid selection. Please try again." >&2
    done
fi

echo "Scanning $subnet through $interface..."
exec arp-scan --interface="$interface" "$subnet"
