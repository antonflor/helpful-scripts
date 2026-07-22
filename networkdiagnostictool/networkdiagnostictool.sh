#!/usr/bin/env bash
set -u -o pipefail

require_command() {
    local command_name=$1
    local package_hint=${2:-$1}
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Required command not found: $command_name (package: $package_hint)" >&2
        return 1
    fi
}

run_privileged() {
    if ((EUID == 0)); then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "This action requires root privileges and sudo is unavailable." >&2
        return 1
    fi
}

select_item() {
    local prompt=$1
    shift
    local -a items=("$@")
    local choice

    if ((${#items[@]} == 0)); then
        return 1
    fi

    for index in "${!items[@]}"; do
        printf '[%d] %s\n' "$((index + 1))" "${items[index]}"
    done

    read -r -p "$prompt" choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#items[@]})); then
        echo "Invalid selection." >&2
        return 1
    fi

    SELECTED_ITEM=${items[choice-1]}
}

prompt_nonempty() {
    local prompt=$1
    local value
    read -r -p "$prompt" value
    if [[ -z "$value" ]]; then
        echo "A value is required." >&2
        return 1
    fi
    PROMPT_VALUE=$value
}

network_scan() {
    require_command ip iproute2 || return
    require_command nmap nmap || return

    mapfile -t subnets < <(
        ip -o -4 addr show up scope global |
            awk '{print $2 " -> " $4}' |
            sort -u
    )

    if ! select_item "Select a subnet: " "${subnets[@]}"; then
        echo "No subnet selected." >&2
        return
    fi

    subnet=${SELECTED_ITEM#* -> }
    echo "Running host discovery on $subnet..."
    nmap -sn "$subnet"
}

performance_test() {
    local iperf_command
    if command -v iperf3 >/dev/null 2>&1; then
        iperf_command=iperf3
    elif command -v iperf >/dev/null 2>&1; then
        iperf_command=iperf
    else
        echo "Install iperf3 (preferred) or iperf before running this test." >&2
        return
    fi

    prompt_nonempty "Iperf server hostname or IP: " || return
    server=$PROMPT_VALUE
    echo "The remote system must be running: $iperf_command -s"
    "$iperf_command" -c "$server"
}

packet_capture() {
    require_command ip iproute2 || return
    require_command tcpdump tcpdump || return

    mapfile -t interfaces < <(
        ip -o link show up |
            awk -F': ' '{print $2}' |
            sed 's/@.*//' |
            sort -u
    )

    select_item "Select an interface: " "${interfaces[@]}" || return
    interface=$SELECTED_ITEM

    read -r -p "Packet count [100]: " packet_count
    packet_count=${packet_count:-100}
    if [[ ! "$packet_count" =~ ^[1-9][0-9]*$ ]]; then
        echo "Packet count must be a positive integer." >&2
        return
    fi

    echo "Capturing $packet_count packets on $interface..."
    run_privileged tcpdump -nn -i "$interface" -c "$packet_count"
}

trace_path() {
    require_command traceroute traceroute || return
    prompt_nonempty "Destination hostname or IP: " || return
    traceroute "$PROMPT_VALUE"
}

dns_query() {
    require_command dig dnsutils || return
    prompt_nonempty "Domain name: " || return
    domain=$PROMPT_VALUE
    read -r -p "DNS record type [A]: " record_type
    record_type=${record_type:-A}
    dig "$domain" "$record_type"
}

interface_and_routing_info() {
    require_command ip iproute2 || return
    echo "IPv4 and IPv6 addresses:"
    ip -brief address
    echo
    echo "Routing tables:"
    ip route show
    ip -6 route show
    echo
    echo "Neighbor table:"
    ip neighbor show
}

socket_summary() {
    require_command ss iproute2 || return
    echo "Socket summary:"
    ss -s
    echo
    echo "Listening TCP and UDP sockets:"
    run_privileged ss -Hltunp
}

port_check() {
    require_command nc netcat-openbsd || return
    prompt_nonempty "Target hostname or IP: " || return
    host=$PROMPT_VALUE
    read -r -p "TCP port: " port
    if [[ ! "$port" =~ ^[0-9]+$ ]] || ((port < 1 || port > 65535)); then
        echo "Port must be between 1 and 65535." >&2
        return
    fi
    nc -zv -w 5 "$host" "$port"
}

snmp_query() {
    require_command snmpwalk snmp || return
    prompt_nonempty "SNMP agent hostname or IP: " || return
    agent=$PROMPT_VALUE
    read -r -s -p "SNMPv2c community: " community
    echo
    if [[ -z "$community" ]]; then
        echo "A community string is required." >&2
        return
    fi
    read -r -p "OID [1.3.6.1.2.1.1]: " oid
    oid=${oid:-1.3.6.1.2.1.1}
    snmpwalk -v2c -c "$community" "$agent" "$oid"
}

show_menu() {
    cat <<'EOF'

Network Diagnostic Toolkit
1. Discover hosts with nmap
2. Run an iperf client test
3. Capture packets with tcpdump
4. Trace a network path
5. Query DNS
6. Show interfaces, routes, and neighbors
7. Show socket and listener information
8. Check a TCP port
9. Run an SNMPv2c walk
0. Exit
EOF
}

while true; do
    show_menu
    read -r -p "Choice: " choice
    case "$choice" in
        1) network_scan ;;
        2) performance_test ;;
        3) packet_capture ;;
        4) trace_path ;;
        5) dns_query ;;
        6) interface_and_routing_info ;;
        7) socket_summary ;;
        8) port_check ;;
        9) snmp_query ;;
        0) echo "Exiting."; exit 0 ;;
        *) echo "Invalid choice." >&2 ;;
    esac
done
