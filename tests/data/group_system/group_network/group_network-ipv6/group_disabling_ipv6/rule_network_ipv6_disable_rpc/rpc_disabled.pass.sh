#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7
# remediation = bash

sed -i "/^tcp6[[:space:]]\+tpi_.*inet6.*/d" /etc/netconfig
sed -i "/^udp6[[:space:]]\+tpi_.*inet6.*/d" /etc/netconfig
