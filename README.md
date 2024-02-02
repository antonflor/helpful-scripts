# Helpful Scripts

This repository contains a collection of useful scripts for various tasks, primarily focused on network management and system administration. These scripts are designed to simplify and automate common tasks in network and system management.

## Scripts Included

### 1. AutoNetDiscover (`autonetdiscover.sh`)

#### Description

A network scanning tool for Debian-based systems. It allows users to select a network interface and subnet, and then uses `arp-scan` to identify active devices in the chosen subnet. The output includes IP and MAC addresses of all detected devices, sorted by IP addresses. This script is ideal for network monitoring and auditing. It requires root privileges and should be used only in authorized environments.

#### Usage

Run the script with root privileges:

```
sudo ./network_scanner.sh
```

Follow the prompts to select a network interface and a subnet for scanning.

### 2. MultiHostCommander (`multihostcommander.sh`)

#### Description

MultiHostCommander is a bash script designed for executing a set of commands on multiple Debian-based hosts. It prompts users for two files: one containing SSH-accessible hosts and another with the commands to run. This tool streamlines batch operations on multiple servers, making it ideal for system administrators managing large networks.

#### Usage

1. Prepare a file with the list of commands to execute (e.g., `commands.txt`).
2. Prepare another file with the list of hosts, each on a new line (e.g., `hosts.txt`).
3. Run the script:

```
./multihostcommander.sh
```

4. When prompted, enter the names of the command and host files.

Ensure SSH keys are set up for passwordless authentication to each host before using this script.

## Contributing

Contributions to this repository are welcome. If you have a useful script that can benefit system administrators and network professionals, feel free to create a pull request.

## License

This repository is open-sourced under the MIT License. See the LICENSE file for more details.

## Disclaimer

Scripts in this repository should be used responsibly and ethically. Ensure that you have the proper authorization before running any script in a network or system environment.
