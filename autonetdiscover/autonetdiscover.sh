#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Function to get subnets from interfaces
get_subnets() {
    ip -o addr show | awk '$3 == "inet" {print $4}'
}

# Function to get network interfaces
get_interfaces() {
    ip -o link show | awk -F': ' '{print $2}' | awk '{print $1}'
}

# Present subnets as options
echo "Available Subnets:"
subnets=($(get_subnets))
select subnet in "${subnets[@]}"; do
    if [ -n "$subnet" ]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Present interfaces as options
echo "Available Interfaces:"
interfaces=($(get_interfaces))
select interface in "${interfaces[@]}"; do
    if [ -n "$interface" ]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Scan the chosen subnet for hosts and sort the output
echo "Scanning for active hosts on $subnet using interface $interface..."
sudo arp-scan --interface="$interface" "$subnet" | sort -t . -k 3,3n -k 4,4n
