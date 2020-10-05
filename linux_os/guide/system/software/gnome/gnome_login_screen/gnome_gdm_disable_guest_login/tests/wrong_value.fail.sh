#!/bin/bash
# packages = gdm

if grep -q "^TimedLoginEnable=" /etc/gdm/custom.conf ; then
	sed -i "s/^TimedLoginEnable=.*/TimedLoginEnable=True/g" /etc/gdm/custom.conf
else
	sed -i "/^\[daemon\]/a \
		TimedLoginEnable=True" /etc/gdm/custom.conf
fi
