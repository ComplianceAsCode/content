# platform = Red Hat Enterprise Linux 7,multi_platform_fedora

if grep -q 'OPTIONS=.*' /etc/sysconfig/ntpd; then
	# trying to solve cases where the parameter after OPTIONS
	#may or may not be enclosed in quotes
	sed -i -E 's/^([\s]*OPTIONS=["]?[^"]*)("?)/\1 -u ntp:ntp\2/' /etc/sysconfig/ntpd
else
	echo 'OPTIONS="-u ntp:ntp"' >> /etc/sysconfig/ntpd
fi
