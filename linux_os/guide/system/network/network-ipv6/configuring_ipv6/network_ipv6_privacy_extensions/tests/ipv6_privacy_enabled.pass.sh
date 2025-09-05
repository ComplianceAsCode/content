#!/bin/bash
#

for interface in /etc/sysconfig/network-scripts/ifcfg-*
do
    echo "IPV6_PRIVACY=rfc3041" >> $interface
done
