# README for AutoNetDiscover.sh

## AutoNetDiscover.sh

### Description

AutoNetDiscover.sh is a Bash script for Debian-based systems that facilitates network discovery by scanning for active hosts within a user-selected subnet and network interface. This script is ideal for network administrators and IT professionals for tasks like network monitoring and auditing. It requires root privileges to operate.

### Features

- Interactive selection of network interfaces and subnets.
- Automated scanning of the chosen subnet for active hosts.
- Outputs a list of active hosts, sorted by IP addresses.

### Requirements

- Bash shell environment.
- `arp-scan` tool must be installed.
- Root access is required to run the script.

### Usage

1. Ensure the `arp-scan` tool is installed on your system.

2. Run the script with root privileges:

   ```
   sudo ./autonetdiscover.sh
   ```

3. Select the desired network interface and subnet from the presented lists.

4. The script will then scan the subnet and display the active hosts.

### Running the Script

To execute the script, follow these steps:

1. Open a terminal window.

2. Navigate to the directory containing `autonetdiscover.sh`.

3. Make the script executable (if not already) using:

   ```
   chmod +x autonetdiscover.sh
   ```

4. Run the script with `sudo`:

   ```
   sudo ./autonetdiscover.sh
   ```

### Important Note

Network scanning can be seen as intrusive in certain environments. Always ensure you have proper authorization and are compliant with applicable policies and regulations before conducting network scans.
