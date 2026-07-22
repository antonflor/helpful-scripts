# AutoNetDiscover

`autonetdiscover.sh` is a small interactive wrapper around `arp-scan`. It lists the IPv4 subnet attached to each active interface, keeps each subnet paired with the correct interface, and scans the selected network.

## Why the interface/subnet pairing matters

A host can have several interfaces, VLANs, bonds, or bridges. Selecting an interface and subnet independently can send a scan through the wrong Layer 2 segment. AutoNetDiscover presents valid pairs reported by `ip addr` and rejects mismatched non-interactive arguments.

## Requirements

- Bash 4 or newer
- `ip` from `iproute2`
- `arp-scan`
- Root privileges or equivalent raw-packet capabilities

On Debian or Ubuntu:

```bash
sudo apt install arp-scan iproute2
```

## Usage

Interactive mode:

```bash
chmod +x autonetdiscover.sh
sudo ./autonetdiscover.sh
```

Non-interactive mode:

```bash
sudo ./autonetdiscover.sh --interface eth0 --subnet 192.0.2.10/24
```

The CIDR must exactly match an address/prefix currently assigned to the selected interface. Run `./autonetdiscover.sh --help` for the option summary.

## Safety

Use this utility only on networks you own or are authorized to assess. ARP scanning generates broadcast traffic on the selected Layer 2 segment.
