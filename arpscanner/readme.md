# Network ARP Scanner

A Python script that ARP-scans the local network(s) attached to your machine and lists each active device's IP and MAC address, sorted by IP, with a per-interface host count.

## Features

- Auto-detects all IPv4 interfaces (loopback excluded) and derives each one's real network from its netmask — no hardcoded subnet assumptions.
- Skips networks larger than /16 to avoid unreasonably long scans.
- Sorted, per-interface output with a total host count.

## Requirements

- Python 3
- `scapy` and `netifaces` libraries:

  ```
  pip install scapy netifaces
  ```

- Root privileges (raw packet access).

## Usage

```
sudo python3 arpscanner.py
```

## Disclaimer

Ensure you have authorization before scanning any network.
