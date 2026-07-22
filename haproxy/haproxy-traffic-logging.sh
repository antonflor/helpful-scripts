#!/usr/bin/env bash
set -Eeuo pipefail

config_dir=/etc/haproxy
duration=60
interval=1

usage() {
    cat <<'EOF'
Usage: haproxy-traffic-logging.sh [options]

Select a backend server declared by an HAProxy "server" directive and display
matching established TCP connections at regular intervals.

Options:
  --config-dir DIR  HAProxy configuration directory (default: /etc/haproxy)
  --duration SEC    Monitoring duration in seconds (default: 60)
  --interval SEC    Seconds between snapshots (default: 1)
  -h, --help        Show this help text
EOF
}

while (($#)); do
    case "$1" in
        --config-dir)
            [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
            config_dir=$2
            shift 2
            ;;
        --duration)
            [[ $# -ge 2 && $2 =~ ^[1-9][0-9]*$ ]] || {
                echo "--duration must be a positive integer" >&2
                exit 2
            }
            duration=$2
            shift 2
            ;;
        --interval)
            [[ $# -ge 2 && $2 =~ ^[1-9][0-9]*$ ]] || {
                echo "--interval must be a positive integer" >&2
                exit 2
            }
            interval=$2
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

for command in awk basename getent sort ss; do
    command -v "$command" >/dev/null 2>&1 || {
        echo "Required command not found: $command" >&2
        exit 1
    }
done

shopt -s nullglob
config_files=("$config_dir"/*.cfg)
if ((${#config_files[@]} == 0)); then
    echo "No .cfg files found in $config_dir." >&2
    exit 1
fi

mapfile -t server_entries < <(
    awk '
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*server[[:space:]]+/ {
            print FILENAME "|" $2 "|" $3
        }
    ' "${config_files[@]}" | sort -u
)

if ((${#server_entries[@]} == 0)); then
    echo "No HAProxy backend server directives were found." >&2
    exit 1
fi

labels=()
valid_entries=()
for entry in "${server_entries[@]}"; do
    IFS='|' read -r file name target <<<"$entry"
    if [[ "$target" =~ ^\[([^]]+)\]:([0-9]+)$ ]]; then
        host=${BASH_REMATCH[1]}
        port=${BASH_REMATCH[2]}
    elif [[ "$target" =~ ^(.+):([0-9]+)$ ]]; then
        host=${BASH_REMATCH[1]}
        port=${BASH_REMATCH[2]}
    else
        continue
    fi

    valid_entries+=("$file|$name|$host|$port")
    labels+=("$(basename "$file"): $name -> $host:$port")
done

if ((${#valid_entries[@]} == 0)); then
    echo "No server directives with an explicit TCP port were found." >&2
    exit 1
fi

echo "Available HAProxy backend servers:"
PS3="Select a server to monitor: "
select label in "${labels[@]}"; do
    if [[ -n "$label" ]]; then
        selected=${valid_entries[REPLY-1]}
        break
    fi
    echo "Invalid selection. Please try again." >&2
done

IFS='|' read -r config_file server_name host port <<<"$selected"

if [[ "$host" =~ ^[0-9a-fA-F:.]+$ ]]; then
    resolved_host=$host
else
    resolved_host=$(getent ahosts "$host" 2>/dev/null | awk 'NR == 1 {print $1}' || true)
    if [[ -z "$resolved_host" ]]; then
        echo "Could not resolve backend hostname: $host" >&2
        exit 1
    fi
fi

echo "Monitoring established TCP connections for $server_name ($resolved_host:$port)."
echo "Configuration: $config_file"
echo "Duration: ${duration}s; interval: ${interval}s"

end_time=$((SECONDS + duration))
while ((SECONDS < end_time)); do
    printf '\n[%(%Y-%m-%d %H:%M:%S)T]\n' -1
    matches=0
    while IFS= read -r connection; do
        if [[ "$connection" == *"$resolved_host"* && "$connection" == *":$port"* ]]; then
            printf '%s\n' "$connection"
            matches=$((matches + 1))
        fi
    done < <(ss -Htn state established)

    if ((matches == 0)); then
        echo "No matching established connections."
    fi
    sleep "$interval"
done

echo "Monitoring complete."
