#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

for interface in /etc/sysconfig/network-scripts/ifcfg-*
do
    echo "IPV6_PRIVACY=rfc3041" >> $interface
done
