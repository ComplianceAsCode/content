#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

yum -y install gdm

if grep -q "^AutomaticLoginEnable=" /etc/gdm/custom.conf ; then
	sed -i "s/^AutomaticLoginEnable=.*/AutomaticLoginEnable=True/g" /etc/gdm/custom.conf
else
	sed -i "/^\[daemon\]/a \
		AutomaticLoginEnable=True" /etc/gdm/custom.conf
fi
