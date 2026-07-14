#!/bin/bash

# Check that ssh-copy-id is available
if ! command -v ssh-copy-id &> /dev/null; then
    echo "ssh-copy-id is not installed. Install the openssh-client package." 1>&2
    exit 1
fi

# Ask the user for the list of hosts
read -p "Enter the hostnames or IP addresses separated by space: " -a hosts

if [ ${#hosts[@]} -eq 0 ]; then
    echo "No hosts entered. Exiting."
    exit 1
fi

failed=()

# Loop through each host and copy the SSH key
for host in "${hosts[@]}"
do
    echo "Copying SSH key to $host..."
    if ! ssh-copy-id "$host"; then
        echo "Failed to copy SSH key to $host."
        failed+=("$host")
    fi
done

if [ ${#failed[@]} -eq 0 ]; then
    echo "SSH keys copied to all specified hosts."
else
    echo "SSH keys copied, but the following hosts failed: ${failed[*]}"
    exit 1
fi
