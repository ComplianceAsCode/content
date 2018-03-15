#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

for file in $(ls /etc/sysconfig/network-scripts/ifcfg-*)
do
    echo "IPV6_PRIVACY=rfc3041" >> $file
done
