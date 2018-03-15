#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

sed -i "/^IPV6_PRIVACY=rfc3041$/d" /etc/sysconfig/network-scripts/ifcfg-*
