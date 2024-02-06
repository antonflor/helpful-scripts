"""
Script Name: Network ARP Scanner
Author: Antonio Flores
Date: 2024-02-05
Version: 1.2

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
    answered_list = scapy.srp(arp_request_broadcast, timeout=15, verbose=False)[0]  # Increased timeout

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
        if ni.AF_INET in addrs:
            ip_addr = addrs[ni.AF_INET][0]['addr']
            # Skip the loopback interface
            if ip_addr.startswith("127."):
                continue
            networks[interface] = ip_addr + '/24'
    return networks

def main():
    networks = get_networks()
    for interface, ip_range in networks.items():
        print(f"Scanning {ip_range} on {interface}")
        scan_result = scan(ip_range)
        display_result(interface, scan_result)

if __name__ == "__main__":
    main()
