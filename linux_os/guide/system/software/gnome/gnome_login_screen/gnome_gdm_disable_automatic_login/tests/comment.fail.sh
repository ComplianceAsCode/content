#!/bin/bash
# packages = gdm

if grep -q "^AutomaticLoginEnable=" /etc/gdm/custom.conf ; then
	sed -i "s/^AutomaticLoginEnable=.*/#AutomaticLoginEnable=False/g" /etc/gdm/custom.conf
else
	sed -i "/^\[daemon\]/a \
		#AutomaticLoginEnable=False" /etc/gdm/custom.conf
fi
