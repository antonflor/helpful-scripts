# HAProxy Host Monitoring Script
#
# This Bash script is designed for monitoring hostnames, IPs, and ports configured in HAProxy.
# It's particularly useful for administrators needing to track source inbound traffic to specific
# hosts managed by HAProxy.
#
# Script Overview:
#
# 1. Extract Host Information: The script starts by extracting hostnames, IPs, and ports from
#    HAProxy configuration files located in `/etc/haproxy/`. It uses `grep`, `awk`, `sed`, `sort`,
#    and `uniq` to parse and format the data.
#
# 2. List Hostnames: It then displays a list of available hostnames for the user to choose from.
#
# 3. User Input for Host Selection: The user is prompted to select a hostname by entering the
#    corresponding number.
#
# 4. Extract Selected Host Details: Based on the user's choice, the script extracts the specific
#    hostname, IP, and port.
#
# 5. Monitor Inbound Traffic: The script monitors the source inbound traffic for the selected host
#    (IP and port) for 60 seconds. It uses the `ss` command to track the traffic.
#
# 6. Loop for 60 Seconds: The monitoring occurs in a loop that lasts for 60 seconds, refreshing
#    the traffic data every second.
#
# 7. End of Monitoring: After 60 seconds, the script concludes the monitoring process and notifies
#    the user.
#
# Usage:
#
# - Run the script in a Bash environment.
# - Ensure you have read access to HAProxy configuration files.
# - The script requires `ss` command for monitoring network connections.
#
# Note:
#
# - This script should be run with appropriate permissions to access HAProxy configuration files.
# - It's designed for quick, real-time monitoring and does not log the output to a file.
# - Use this script responsibly, especially in production environments, as continuous monitoring
#   might impact system performance.


#!/bin/bash

# Command to get hostnames, IPs, and ports
output=$(grep node /etc/haproxy/*.cfg | awk '{print $1 $4}' | sed 's|/etc/haproxy/||;s|.cfg:| |;s|:| |1' | sort | uniq)

# Generate a list of hostnames
echo "Available Hostnames:"
echo "$output" | awk '{print NR ": " $1}'
echo "---------------------"

# Ask the user to choose a hostname
read -p "Enter the number of the hostname you want to check: " choice

# Get the selected line
selected_line=$(echo "$output" | sed -n "${choice}p")

# Extract IP and port
hostname=$(echo "$selected_line" | awk '{print $1}')
ip=$(echo "$selected_line" | awk '{print $2}')
port=$(echo "$selected_line" | awk '{print $3}')

# Display the selected hostname
echo "Checking source inbound traffic for $hostname ($ip:$port) for 60 seconds..."

# Start time
end=$((SECONDS+60))

# Loop for 60 seconds
while [ $SECONDS -lt $end ]; do
    # Run ss command to check source inbound traffic for the IP and port
    ss -tn state all '( dport = :$port or sport = :$port )' and '( dst $ip or src $ip )'
    
    # Sleep for a short interval before running the command again
    sleep 1

    echo "----------------------------------------"
done

echo "Completed monitoring for 60 seconds."
