#!/bin/bash
# packages = firewalld
# remediation = none

# Ensure the required service is started
systemctl start firewalld

# Ensure the trusted zone is overridden by an equivalent file in /etc/firewalld/zones
firewall-cmd --permanent --zone=trusted --add-service=http

# Ensure the there is no rich-rule restricting loopback traffic in trusted zone
firewall-cmd --permanent --zone=trusted --remove-rich-rule='rule family=ipv4 source address="127.0.0.1" destination not address="127.0.0.1" drop'
firewall-cmd --permanent --zone=trusted --remove-rich-rule='rule family=ipv6 source address="::1" destination not address="::1" drop'

mv -f /etc/firewalld/zones/trusted.xml /usr/lib/firewalld/zones/trusted.xml

# Ensure the required service is stopped
systemctl stop firewalld
