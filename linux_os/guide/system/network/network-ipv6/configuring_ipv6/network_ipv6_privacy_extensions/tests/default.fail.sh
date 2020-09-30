#!/bin/bash
#

sed -i "/^IPV6_PRIVACY=rfc3041$/d" /etc/sysconfig/network-scripts/ifcfg-*
