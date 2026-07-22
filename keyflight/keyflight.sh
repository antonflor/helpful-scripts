#!/usr/bin/env bash
set -u -o pipefail

key_file=""
host_file=""
port=""
declare -a hosts=()

usage() {
    cat <<'EOF'
Usage: keyflight.sh [options] [user@host ...]

Copy an SSH public key to one or more hosts with ssh-copy-id.

Options:
  -i, --identity FILE  Public key file to install
  -f, --hosts-file FILE
                       Read hosts from a file (blank lines and comments ignored)
  -p, --port PORT      SSH port used for every host
  -h, --help           Show this help text
EOF
}

while (($#)); do
    case "$1" in
        -i|--identity)
            [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
            key_file=$2
            shift 2
            ;;
        -f|--hosts-file)
            [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
            host_file=$2
            shift 2
            ;;
        -p|--port)
            [[ $# -ge 2 && $2 =~ ^[0-9]+$ && $2 -ge 1 && $2 -le 65535 ]] || {
                echo "SSH port must be between 1 and 65535." >&2
                exit 2
            }
            port=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            hosts+=("$@")
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
        *)
            hosts+=("$1")
            shift
            ;;
    esac
done

command -v ssh-copy-id >/dev/null 2>&1 || {
    echo "ssh-copy-id is unavailable. Install the OpenSSH client package." >&2
    exit 1
}

if [[ -n "$key_file" ]]; then
    if [[ ! -f "$key_file" || ! -r "$key_file" ]]; then
        echo "Public key file is not readable: $key_file" >&2
        exit 1
    fi
    if [[ "$key_file" != *.pub ]]; then
        echo "Warning: $key_file does not use the conventional .pub suffix." >&2
    fi
fi

if [[ -n "$host_file" ]]; then
    if [[ ! -r "$host_file" ]]; then
        echo "Hosts file is not readable: $host_file" >&2
        exit 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        line=${line%$'\r'}
        line=${line%%#*}
        read -r -a line_hosts <<<"$line"
        hosts+=("${line_hosts[@]}")
    done < "$host_file"
fi

if ((${#hosts[@]} == 0)); then
    if [[ -t 0 ]]; then
        read -r -a hosts -p "Enter user@host values separated by spaces: "
    fi
fi

if ((${#hosts[@]} == 0)); then
    echo "No target hosts were provided." >&2
    exit 2
fi

ssh_copy_args=()
[[ -n "$key_file" ]] && ssh_copy_args+=(-i "$key_file")
[[ -n "$port" ]] && ssh_copy_args+=(-p "$port")

declare -A seen=()
declare -a unique_hosts=()
for host in "${hosts[@]}"; do
    [[ -n "$host" ]] || continue
    if [[ "$host" == -* ]]; then
        echo "Refusing host value that begins with '-': $host" >&2
        exit 2
    fi
    if [[ -z "${seen[$host]+x}" ]]; then
        seen[$host]=1
        unique_hosts+=("$host")
    fi
done

failures=()
for host in "${unique_hosts[@]}"; do
    echo "Installing SSH key on $host..."
    if ! ssh-copy-id "${ssh_copy_args[@]}" "$host"; then
        echo "Failed: $host" >&2
        failures+=("$host")
    fi
done

printf '\nSucceeded: %d\n' "$((${#unique_hosts[@]} - ${#failures[@]}))"
printf 'Failed: %d\n' "${#failures[@]}"

if ((${#failures[@]} > 0)); then
    printf 'Failed hosts: %s\n' "${failures[*]}" >&2
    exit 1
fi
