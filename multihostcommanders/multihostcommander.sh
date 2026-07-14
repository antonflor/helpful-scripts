#!/bin/bash

# Function to perform the SSH operation
execute_ssh() {
    local host=$1
    local commands=$2

    echo "--$host"
    # -n prevents ssh from consuming the host list on stdin
    # accept-new trusts unseen hosts but still rejects changed host keys
    ssh -n -o StrictHostKeyChecking=accept-new "$host" "$commands"
}

# Prompt for the filename containing commands
echo "Enter the filename containing the commands:"
read command_file

# Check if the command file exists and is not empty
if [[ ! -s "$command_file" ]]; then
    echo "Command file is empty or does not exist."
    exit 1
fi

# Read commands from the file
commands=$(<"$command_file")

# Prompt for the filename containing hosts
echo "Enter the filename containing the hosts:"
read host_file

# Check if the host file exists and is not empty
if [[ ! -s "$host_file" ]]; then
    echo "Host file is empty or does not exist."
    exit 1
fi

# Read hosts from the file and execute commands on each
while IFS= read -r host; do
    # Skip blank lines and comments
    [[ -z "$host" || "$host" == \#* ]] && continue
    execute_ssh "$host" "$commands"
done < "$host_file"
