#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

if grep -q "^net.ipv6.conf.all.accept_source_route" /etc/sysctl.conf; then
	sed -i "s/^net.ipv6.conf.all.accept_source_route.*/net.ipv6.conf.all.accept_source_route = 1/" /etc/sysctl.conf
else
	echo "net.ipv6.conf.all.accept_source_route = 1" >> /etc/sysctl.conf
fi
