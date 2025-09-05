#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

yum -y install gdm

if grep -q "^TimedLoginEnable=" /etc/gdm/custom.conf ; then
	sed -i "s/^TimedLoginEnable=.*/TimedLoginEnable=True/g" /etc/gdm/custom.conf
else
	sed -i "/^\[daemon\]/a \
		TimedLoginEnable=True" /etc/gdm/custom.conf
fi
