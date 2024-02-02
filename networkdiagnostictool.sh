#!/bin/bash

# Description: This script provides various network diagnostic and monitoring functionalities.

# Global variables (if any) go here

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

function network_scan() {
    echo "Scanning for available subnets..."

    # Get a list of IP addresses and their associated subnets
    local ips=($(ip -o -f inet addr show | awk '/scope global/ {print $4}'))

    if [ ${#ips[@]} -eq 0 ]; then
        echo "No subnets found."
        return
    fi

    echo "Select a subnet to scan:"
    local i=1
    for ip in "${ips[@]}"; do
        echo "[$i] $ip"
        ((i++))
    done

    read -p "Enter your choice: " choice
    local selected_subnet=${ips[$choice-1]}

    if [ -z "$selected_subnet" ]; then
        echo "Invalid choice. Please try again."
        return
    fi

    echo "Starting network scan on $selected_subnet..."
    nmap $selected_subnet
}

function performance_test() {
    # Check if iperf is installed on the client
    if ! command -v iperf &> /dev/null; then
        echo "iperf is not installed. Please install it to proceed."
        return
    fi

    echo "Ensure that iperf is running in server mode on the server."
    read -p "Press [Enter] once confirmed..."

    echo "Starting performance test..."
    read -p "Enter server IP: " server_ip
    iperf -c $server_ip
}


function traffic_analysis() {
    echo "Starting traffic analysis..."

    # List available network interfaces
    local interfaces=($(ip -o link show | awk -F': ' '{print $2}'))

    if [ ${#interfaces[@]} -eq 0 ]; then
        echo "No network interfaces found."
        return
    fi

    echo "Select a network interface:"
    local i=1
    for intf in "${interfaces[@]}"; do
        echo "[$i] $intf"
        ((i++))
    done

    read -p "Enter your choice: " choice
    local selected_interface=${interfaces[$choice-1]}

    if [ -z "$selected_interface" ]; then
        echo "Invalid choice. Please try again."
        return
    fi

    # Capture 100 packets on the selected interface
    tcpdump -i $selected_interface -c 100
}



function show_menu() {
    echo "Network Diagnostic and Monitoring Tool"
    echo "1. Network Scanning and Discovery"
    echo "2. Performance Testing"
    echo "3. Traffic Analysis"
    echo "4. Network Path Tracing"
    echo "5. DNS Query Testing"
    echo "6. Interface and Routing Information"
    echo "7. Packet Sniffing and Inspection"
    echo "8. Basic Port Checking"
    echo "9. SNMP Data Collection"
    echo "0. Exit"
    echo "Enter your choice: "
}

while true; do
    show_menu
    read choice
    case $choice in
        1) network_scan ;;
        2) performance_test ;;
        3) traffic_analysis ;;
        # Add cases for other options here
        0) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice. Please try again."; continue ;;
    esac
done

