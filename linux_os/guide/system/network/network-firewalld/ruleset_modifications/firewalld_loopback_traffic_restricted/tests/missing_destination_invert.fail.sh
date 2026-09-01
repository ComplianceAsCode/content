#!/bin/bash
# packages = firewalld
# remediation = none

# Ensure the required service is started
systemctl start firewalld

# Ensure the trusted zone is overridden by an equivalent file in /etc/firewalld/zones
firewall-cmd --permanent --zone=trusted --add-service=http

# Add rich-rules WITHOUT the "not" keyword on the destination.
# This drops traffic FROM loopback TO loopback rather than
# FROM loopback to non-loopback, which fails to restrict spoofed traffic.
firewall-cmd --permanent --zone=trusted --add-rich-rule='rule family=ipv4 source address="127.0.0.1" destination address="127.0.0.1" drop'
firewall-cmd --permanent --zone=trusted --add-rich-rule='rule family=ipv6 source address="::1" destination address="::1" drop'
