# Network ARP Scanner

A Python utility that discovers active IPv4 hosts on directly connected networks and prints their IP and MAC addresses per interface.

## Improvements and behavior

- Detects IPv4 networks from each interface and its actual netmask.
- Sends each ARP request through the interface that owns the network.
- Supports multiple IPv4 addresses and networks per interface.
- Deduplicates responses and sorts results numerically by IP address.
- Skips loopback and link-local addresses.
- Refuses unexpectedly large scans by default.

## Requirements

- Linux or another Unix-like system with raw-packet support
- Python 3.9 or newer
- Root privileges
- `scapy` and `netifaces`

Install the Python dependencies:

```bash
python3 -m pip install scapy netifaces
```

## Usage

Scan all eligible connected networks:

```bash
sudo python3 arpscanner.py
```

Scan one interface:

```bash
sudo python3 arpscanner.py --interface eth0
```

Select multiple interfaces and change the response timeout:

```bash
sudo python3 arpscanner.py -i eth0 -i bond0 --timeout 5
```

Networks larger than 4,096 addresses are skipped by default. Override the limit only when the scope is intentional:

```bash
sudo python3 arpscanner.py --max-addresses 65536 --allow-large
```

Run `python3 arpscanner.py --help` for all options.

## Safety

ARP scanning is limited to directly connected Layer 2 networks. Run it only on networks you own or are authorized to assess. Large scans can generate substantial broadcast traffic.
