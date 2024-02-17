# Network Diagnostic and Monitoring Tool

This Bash script provides a suite of network diagnostic and monitoring tools to help network and cloud engineers efficiently assess and analyze their network environment. The script is modular and includes functionalities such as network scanning, performance testing, traffic analysis, and more.

## Features

- **Network Scanning and Discovery:** Utilizes `nmap` for network scanning.
- **Performance Testing:** Employs `iperf` for testing network bandwidth.
- **Traffic Analysis:** Leverages `tcpdump` for monitoring network traffic.
- **Network Path Tracing:** Uses `traceroute` to trace packet paths.
- **DNS Query Testing:** Incorporates `dnsutils` for DNS testing.
- **Interface and Routing Information:** Utilizes `iproute2` and `net-tools`.
- **Packet Sniffing and Inspection:** Applies `ngrep` for packet analysis.
- **Basic Port Checking:** Implements `netcat` for port checking.
- **SNMP Data Collection:** Uses `snmpd` for SNMP data gathering.

## Prerequisites

Before running the script, ensure the following tools are installed:

- nmap
- iperf
- tcpdump
- traceroute
- dnsutils
- iproute2
- ngrep
- netcat
- snmpd
- net-tools

## Installation

1. Clone the repository or download the script.
2. Make the script executable:

```
chmod +x NetworkDiagnosticTool.sh
```

## Usage

Run the script with root privileges:

```
sudo ./NetworkDiagnosticTool.sh
```

Follow the on-screen prompts to select the desired network diagnostic or monitoring function.

## Contributing

Contributions to this project are welcome. Please fork the repository and submit a pull request with your improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This tool is intended for network diagnostic and monitoring purposes. Please ensure you have proper authorization before scanning or monitoring any network.
