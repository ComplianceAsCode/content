# platform = Red Hat Enterprise Linux 7

if rpm --quiet -q gdm
then
	if ! grep -q "^TimedLoginEnable=" /etc/gdm/custom.conf
	then
		sed -i "/^\[daemon\]/a \
		TimedLoginEnable=False" /etc/gdm/custom.conf
	else
		sed -i "s/^TimedLoginEnable=.*/TimedLoginEnable=False/g" /etc/gdm/custom.conf
	fi
fi
