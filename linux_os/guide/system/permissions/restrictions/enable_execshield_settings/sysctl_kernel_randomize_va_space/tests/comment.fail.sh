#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^kernel.randomize_va_space" /etc/sysctl.conf; then
	sed -i "s/^kernel.randomize_va_space.*/# kernel.randomize_va_space = 2/" /etc/sysctl.conf
else
	echo "# kernel.randomize_va_space = 2" >> /etc/sysctl.conf
fi
