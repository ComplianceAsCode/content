#!/bin/bash
# packages = gdm

if grep -q "^TimedLoginEnable=" /etc/gdm/custom.conf ; then
	sed -i "s/^TimedLoginEnable=.*/TimedLoginEnable=False/g" /etc/gdm/custom.conf
else
	sed -i "/^\[daemon\]/a \
		TimedLoginEnable=False" /etc/gdm/custom.conf
fi
