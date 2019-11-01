#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp, xccdf_org.ssgproject.content_profile_stig-rhel7-server-upstream

sed -i "/^net.ipv6.conf.all.accept_source_route.*/d" /etc/sysctl.conf

sysctl -w net.ipv6.conf.all.accept_source_route=0
