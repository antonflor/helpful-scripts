# Network Diagnostic Toolkit

This interactive Bash utility groups common network inspection and troubleshooting commands behind a menu. It checks dependencies only when a feature is selected and requests elevated privileges only for actions that need them.

## Features

1. **Host discovery** — `nmap -sn` against a locally attached IPv4 subnet
2. **Bandwidth testing** — `iperf3` or legacy `iperf` client mode
3. **Packet capture** — bounded `tcpdump` capture on a selected active interface
4. **Path tracing** — `traceroute`
5. **DNS lookup** — `dig` with a selectable record type
6. **Local network state** — addresses, IPv4/IPv6 routes, and neighbors via `ip`
7. **Socket inspection** — `ss` summary and listening sockets
8. **TCP port check** — `nc` with a five-second timeout
9. **SNMP query** — SNMPv2c `snmpwalk` with hidden community-string input

## Requirements

Install only the tools you need. On Debian or Ubuntu, the complete set is:

```bash
sudo apt install \
  iproute2 \
  nmap \
  iperf3 \
  tcpdump \
  traceroute \
  dnsutils \
  netcat-openbsd \
  snmp
```

The toolkit no longer requires the entire menu to run as root. It invokes `sudo` for packet capture and privileged socket/process details when needed.

## Usage

```bash
chmod +x networkdiagnostictool.sh
./networkdiagnostictool.sh
```

Follow the menu prompts. Press `Ctrl+C` to stop a long-running command such as `tcpdump`, `traceroute`, or `snmpwalk`.

## Operational notes

- Host discovery uses `nmap -sn`, which discovers responsive hosts without performing a default port scan.
- Iperf requires a remote server started with `iperf3 -s` or `iperf -s`.
- SNMPv2c community strings are credentials and are transmitted without encryption. Prefer SNMPv3 where security is required.
- Packet capture and network scanning should be performed only with proper authorization.
