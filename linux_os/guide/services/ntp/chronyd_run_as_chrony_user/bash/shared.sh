# platform = Red Hat Enterprise Linux 7,multi_platform_fedora,Red Hat Enterprise Linux 8

if grep -q 'OPTIONS=.*' /etc/sysconfig/chronyd; then
	# trying to solve cases where the parameter after OPTIONS
	#may or may not be enclosed in quotes
	sed -i -E -e 's/\s*-u\s+\w+\s*/ /' -e 's/^([\s]*OPTIONS=["]?[^"]*)("?)/\1 -u chrony\2/' /etc/sysconfig/chronyd
else
	echo 'OPTIONS="-u chrony"' >> /etc/sysconfig/chronyd
fi
