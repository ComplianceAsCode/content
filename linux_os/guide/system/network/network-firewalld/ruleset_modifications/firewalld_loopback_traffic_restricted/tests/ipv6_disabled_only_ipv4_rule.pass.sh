#!/bin/bash
# packages = firewalld

# Ensure the required service is started
systemctl start firewalld

# Disable IPv6 both statically and at runtime
echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/99-disable-ipv6.conf
sysctl -w net.ipv6.conf.all.disable_ipv6=1

# Ensure the trusted zone is overridden by an equivalent file in /etc/firewalld/zones
firewall-cmd --permanent --zone=trusted --add-service=http

# Add only the IPv4 rich-rule. With IPv6 disabled, the IPv6 rule is not required.
firewall-cmd --permanent --zone=trusted --add-rich-rule='rule family=ipv4 source address="127.0.0.1" destination not address="127.0.0.1" drop'
