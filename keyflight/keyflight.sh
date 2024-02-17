#!/bin/bash

# Ask the user for the list of hosts
read -p "Enter the hostnames or IP addresses separated by space: " -a hosts

# Loop through each host and copy the SSH key
for host in "${hosts[@]}"
do
    echo "Copying SSH key to $host..."
    ssh-copy-id "$host"
done

echo "SSH keys copied to all specified hosts."
