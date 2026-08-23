#!/bin/bash
# packages = firewalld
# remediation = none

# Ensure the required service is started
systemctl start firewalld

# Ensure the trusted zone is overridden by an equivalent file in /etc/firewalld/zones
firewall-cmd --permanent --zone=trusted --add-service=http

# Add only the IPv4 rich-rule, omitting the IPv6 rule.
# The policy requires both families to be restricted.
firewall-cmd --permanent --zone=trusted --add-rich-rule='rule family=ipv4 source address="127.0.0.1" destination not address="127.0.0.1" drop'
