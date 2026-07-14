# Helpful Scripts

A collection of useful scripts for network management and system administration. These scripts are designed to simplify and automate common tasks for sysadmins, network engineers, and homelab tinkerers.

## Script Index

| Script | Language | Description |
| --- | --- | --- |
| [arpscanner](arpscanner/) | Python | ARP-scans your local networks and lists active devices (IP + MAC) per interface. |
| [autonetdiscover](autonetdiscover/) | Bash | Interactive host discovery on a chosen subnet/interface using `arp-scan`. |
| [docker-auto-install](docker-auto-install/) | Bash | Installs Docker Engine on Debian from the official Docker repository. |
| [haproxy](haproxy/) | Bash | Monitors live inbound traffic for a host/port pulled from your HAProxy configs. |
| [keyflight](keyflight/) | Bash | Copies your SSH public key to multiple hosts in one shot (`ssh-copy-id` loop). |
| [kvm-auto-install](kvm-auto-install/) | Bash | Installs KVM/QEMU + libvirt on Debian-based systems and verifies the setup. |
| [multihostcommanders](multihostcommanders/) | Bash | Runs a set of commands on a list of hosts over SSH. |
| [networkdiagnostictool](networkdiagnostictool/) | Bash | Menu-driven network toolkit: scanning, iperf, tcpdump, traceroute, DNS, SNMP, and more. |
| [plexmediaserver](plexmediaserver/) | Bash | Downloads and installs the latest Plex Media Server on Debian. |
| [powershell](powershell/) | PowerShell | Interactive SMART health check for physical drives on Windows. |

Each folder contains its own README with usage details.

## Contributing

Contributions to this repository are welcome. If you have a useful script that can benefit system administrators and network professionals, feel free to create a pull request.

## License

This repository is open-sourced under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Disclaimer

Scripts in this repository should be used responsibly and ethically. Ensure that you have the proper authorization before running any script in a network or system environment.
