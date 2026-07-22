#!/usr/bin/env python3
"""Discover IPv4 hosts on directly connected networks with ARP requests."""

from __future__ import annotations

import argparse
import ipaddress
import os
import sys
from collections.abc import Iterable

netifaces = None
ARP = None
Ether = None
srp = None

DEFAULT_TIMEOUT = 3.0
DEFAULT_MAX_ADDRESSES = 4096


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="ARP-scan IPv4 networks attached to local interfaces."
    )
    parser.add_argument(
        "-i",
        "--interface",
        action="append",
        dest="interfaces",
        help="scan only this interface; repeat to select multiple interfaces",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=DEFAULT_TIMEOUT,
        help=f"response timeout in seconds (default: {DEFAULT_TIMEOUT:g})",
    )
    parser.add_argument(
        "--max-addresses",
        type=int,
        default=DEFAULT_MAX_ADDRESSES,
        help=(
            "skip networks larger than this many addresses "
            f"(default: {DEFAULT_MAX_ADDRESSES})"
        ),
    )
    parser.add_argument(
        "--allow-large",
        action="store_true",
        help="scan networks larger than --max-addresses",
    )
    return parser.parse_args()


def load_dependencies() -> None:
    global netifaces, ARP, Ether, srp
    try:
        import netifaces as loaded_netifaces
        from scapy.all import ARP as loaded_arp
        from scapy.all import Ether as loaded_ether
        from scapy.all import srp as loaded_srp
    except ImportError as exc:  # pragma: no cover - depends on the local environment
        missing = exc.name or "a required dependency"
        raise RuntimeError(
            f"Missing Python dependency: {missing}. Install requirements with: "
            "python3 -m pip install scapy netifaces"
        ) from exc

    netifaces = loaded_netifaces
    ARP = loaded_arp
    Ether = loaded_ether
    srp = loaded_srp


def require_root() -> None:
    if hasattr(os, "geteuid") and os.geteuid() != 0:
        raise PermissionError("raw ARP scanning requires root privileges")


def discover_networks(
    selected_interfaces: set[str] | None = None,
) -> list[tuple[str, ipaddress.IPv4Network]]:
    discovered: set[tuple[str, ipaddress.IPv4Network]] = set()

    for interface in netifaces.interfaces():
        if selected_interfaces and interface not in selected_interfaces:
            continue

        try:
            ipv4_addresses = netifaces.ifaddresses(interface).get(
                netifaces.AF_INET, []
            )
        except (OSError, ValueError):
            continue

        for address in ipv4_addresses:
            ip_text = address.get("addr")
            netmask = address.get("netmask")
            if not ip_text or not netmask:
                continue

            try:
                ip_address = ipaddress.ip_address(ip_text)
                network = ipaddress.ip_network(f"{ip_text}/{netmask}", strict=False)
            except ValueError:
                continue

            if not isinstance(ip_address, ipaddress.IPv4Address):
                continue
            if ip_address.is_loopback or ip_address.is_link_local:
                continue

            discovered.add((interface, network))

    return sorted(discovered, key=lambda item: (item[0], item[1].network_address))


def scan_network(
    interface: str,
    network: ipaddress.IPv4Network,
    timeout: float,
) -> list[dict[str, str]]:
    packet = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst=str(network))
    answered = srp(
        packet,
        iface=interface,
        timeout=timeout,
        retry=1,
        verbose=False,
    )[0]

    clients: dict[ipaddress.IPv4Address, str] = {}
    for _, response in answered:
        try:
            address = ipaddress.ip_address(response.psrc)
        except ValueError:
            continue
        if isinstance(address, ipaddress.IPv4Address):
            clients[address] = response.hwsrc.lower()

    return [
        {"ip": str(address), "mac": clients[address]}
        for address in sorted(clients)
    ]


def display_results(
    interface: str,
    network: ipaddress.IPv4Network,
    clients: Iterable[dict[str, str]],
) -> None:
    rows = list(clients)
    print(f"\nResults for {interface} ({network})")
    print(f"{'IP address':<16} MAC address")
    print(f"{'-' * 16} {'-' * 17}")
    for client in rows:
        print(f"{client['ip']:<16} {client['mac']}")
    print(f"Hosts found: {len(rows)}")


def main() -> int:
    args = parse_args()

    if args.timeout <= 0:
        print("--timeout must be greater than zero", file=sys.stderr)
        return 2
    if args.max_addresses <= 0:
        print("--max-addresses must be greater than zero", file=sys.stderr)
        return 2

    try:
        load_dependencies()
    except RuntimeError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 2

    try:
        require_root()
    except PermissionError as exc:
        print(f"Error: {exc}. Run with sudo.", file=sys.stderr)
        return 1

    selected_interfaces = set(args.interfaces) if args.interfaces else None
    if selected_interfaces:
        unknown = selected_interfaces.difference(netifaces.interfaces())
        if unknown:
            print(
                f"Unknown interface(s): {', '.join(sorted(unknown))}",
                file=sys.stderr,
            )
            return 2

    networks = discover_networks(selected_interfaces)
    if not networks:
        print("No eligible IPv4 networks found.", file=sys.stderr)
        return 1

    scanned = 0
    for interface, network in networks:
        if network.num_addresses > args.max_addresses and not args.allow_large:
            print(
                f"Skipping {network} on {interface}: {network.num_addresses} addresses "
                f"exceeds --max-addresses {args.max_addresses}",
                file=sys.stderr,
            )
            continue

        print(f"Scanning {network} on {interface}...")
        try:
            clients = scan_network(interface, network, args.timeout)
        except PermissionError as exc:
            print(f"Scan failed on {interface}: {exc}", file=sys.stderr)
            continue
        except OSError as exc:
            print(f"Scan failed on {interface}: {exc}", file=sys.stderr)
            continue

        display_results(interface, network, clients)
        scanned += 1

    if scanned == 0:
        print("No networks were scanned.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
