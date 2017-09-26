#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

# ensure firewalld installed
yum install firewalld

firewall-cmd --permanent --zone=public --add-service=ssh

eth_interface=$(ip link show up | cut -d ' ' -f2 | cut -d ':' -s -f1 | grep -E '^(en|eth)')

firewall-cmd --permanent --zone=public --add-interface=${eth_interface[0]}
