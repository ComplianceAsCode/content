#!/bin/bash
# packages = gdm


if grep -q "^AutomaticLoginEnable=" /etc/gdm/custom.conf ; then
	sed -i "s/^AutomaticLoginEnable=.*/AutomaticLoginEnable=True/g" /etc/gdm/custom.conf
else
	sed -i "/^\[daemon\]/a \
		AutomaticLoginEnable=True" /etc/gdm/custom.conf
fi
