"""
Script Name: Network ARP Scanner
Author: Antonio Flores
Date: 2026-07-14
Version: 1.3

Description:
    This script performs an ARP scan on the local network to identify active devices.
    It lists each device's IP and MAC address.

Usage:
    Run the script with Python 3. Requires 'scapy' and 'netifaces' libraries. Requires sudo.

Disclaimer:
    This script is for educational purposes only. Ensure you have authorization before scanning any network.
"""

import scapy.all as scapy
import netifaces as ni
import ipaddress

def scan(ip):
    arp_request = scapy.ARP(pdst=ip)
    broadcast = scapy.Ether(dst="ff:ff:ff:ff:ff:ff")
    arp_request_broadcast = broadcast/arp_request
    answered_list = scapy.srp(arp_request_broadcast, timeout=3, verbose=False)[0]

    clients_list = []
    for element in answered_list:
        client_dict = {"ip": element[1].psrc, "mac": element[1].hwsrc}
        clients_list.append(client_dict)
    return clients_list

def display_result(interface, results_list):
    print(f"\nResults for {interface}:")
    print("IP\t\t\tMAC Address\n-----------------------------------------")

    # Sort the results based on IP addresses
    sorted_results = sorted(results_list, key=lambda x: ipaddress.ip_address(x['ip']))

    for client in sorted_results:
        print(client["ip"] + "\t\t" + client["mac"])

    # Display total count of hosts found
    print(f"\nTotal hosts found on {interface}: {len(sorted_results)}\n")

def get_networks():
    networks = {}
    for interface in ni.interfaces():
        addrs = ni.ifaddresses(interface)
        if ni.AF_INET not in addrs:
            continue
        addr_info = addrs[ni.AF_INET][0]
        ip_addr = addr_info['addr']
        # Skip the loopback interface
        if ip_addr.startswith("127."):
            continue
        # Build the real network from the interface netmask instead of assuming /24
        netmask = addr_info.get('netmask', '255.255.255.0')
        network = ipaddress.ip_network(f"{ip_addr}/{netmask}", strict=False)
        # Skip networks too large to ARP-scan in a reasonable time
        if network.prefixlen < 16:
            print(f"Skipping {network} on {interface}: network larger than /16")
            continue
        networks[interface] = str(network)
    return networks

def main():
    networks = get_networks()
    if not networks:
        print("No scannable networks found.")
        return
    for interface, ip_range in networks.items():
        print(f"Scanning {ip_range} on {interface}")
        scan_result = scan(ip_range)
        display_result(interface, scan_result)

if __name__ == "__main__":
    main()
