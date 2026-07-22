#!/usr/bin/env bash
set -u -o pipefail

host_file=""
command_file=""
remote_shell=sh
connect_timeout=10
accept_new=false

usage() {
    cat <<'EOF'
Usage: multihostcommander.sh [options]

Execute a local command file on each SSH host listed in a host file.

Options:
  -H, --hosts FILE       Host file (one user@host or SSH alias per line)
  -C, --commands FILE    Commands sent to the remote shell
  --shell NAME           Remote shell command (default: sh)
  --connect-timeout SEC  SSH connection timeout (default: 10)
  --accept-new           Trust previously unseen host keys
  -h, --help             Show this help text
EOF
}

while (($#)); do
    case "$1" in
        -H|--hosts)
            [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
            host_file=$2
            shift 2
            ;;
        -C|--commands)
            [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
            command_file=$2
            shift 2
            ;;
        --shell)
            [[ $# -ge 2 && $2 =~ ^[A-Za-z0-9_./-]+$ ]] || {
                echo "Invalid remote shell value." >&2
                exit 2
            }
            remote_shell=$2
            shift 2
            ;;
        --connect-timeout)
            [[ $# -ge 2 && $2 =~ ^[1-9][0-9]*$ ]] || {
                echo "Connection timeout must be a positive integer." >&2
                exit 2
            }
            connect_timeout=$2
            shift 2
            ;;
        --accept-new)
            accept_new=true
            shift
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

command -v ssh >/dev/null 2>&1 || {
    echo "OpenSSH client is required." >&2
    exit 1
}

if [[ -z "$host_file" && -t 0 ]]; then
    read -r -p "Host file: " host_file
fi
if [[ -z "$command_file" && -t 0 ]]; then
    read -r -p "Command file: " command_file
fi

if [[ ! -s "$host_file" ]]; then
    echo "Host file is missing or empty: $host_file" >&2
    exit 1
fi
if [[ ! -s "$command_file" ]]; then
    echo "Command file is missing or empty: $command_file" >&2
    exit 1
fi

hosts=()
declare -A seen=()
while IFS= read -r host || [[ -n "$host" ]]; do
    host=${host%$'\r'}
    host=${host%%#*}
    read -r host _ <<<"$host"
    [[ -n "$host" ]] || continue
    if [[ "$host" == -* ]]; then
        echo "Refusing host value that begins with '-': $host" >&2
        exit 2
    fi
    if [[ -z "${seen[$host]+x}" ]]; then
        seen[$host]=1
        hosts+=("$host")
    fi
done < "$host_file"

if ((${#hosts[@]} == 0)); then
    echo "No usable hosts were found in $host_file." >&2
    exit 1
fi

ssh_options=(
    -T
    -o BatchMode=yes
    -o ConnectTimeout="$connect_timeout"
)
if [[ "$accept_new" == true ]]; then
    ssh_options+=(-o StrictHostKeyChecking=accept-new)
else
    ssh_options+=(-o StrictHostKeyChecking=yes)
fi

failures=()
for host in "${hosts[@]}"; do
    printf '\n===== %s =====\n' "$host"
    if ! ssh "${ssh_options[@]}" "$host" "$remote_shell -s" < "$command_file"; then
        failures+=("$host")
        echo "Command execution failed on $host." >&2
    fi
done

printf '\nSucceeded: %d\n' "$((${#hosts[@]} - ${#failures[@]}))"
printf 'Failed: %d\n' "${#failures[@]}"

if ((${#failures[@]} > 0)); then
    printf 'Failed hosts: %s\n' "${failures[*]}" >&2
    exit 1
fi
