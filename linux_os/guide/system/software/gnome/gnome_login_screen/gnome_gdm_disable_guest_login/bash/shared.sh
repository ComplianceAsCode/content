# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol

if rpm --quiet -q gdm
then
	if ! grep -q "^TimedLoginEnable=" /etc/gdm/custom.conf
	then
		sed -i "/^\[daemon\]/a \
		TimedLoginEnable=false" /etc/gdm/custom.conf
	else
		sed -i "s/^TimedLoginEnable=.*/TimedLoginEnable=false/g" /etc/gdm/custom.conf
	fi
fi
