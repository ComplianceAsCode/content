# platform = multi_platform_fedora,multi_platform_ubuntu,debian12

if grep -q 'OPTIONS=.*' /etc/systemd/system/ntpd.service; then
	# trying to solve cases where the parameter after OPTIONS
	#may or may not be enclosed in quotes
	sed -i -E 's/^([\s]*OPTIONS=["]?[^"]*)("?)/\1 -u ntpsec:ntpsec\2/' /etc/systemd/system/ntpd.service
else
	echo 'OPTIONS="-u ntpsec:ntpsec"' >> /etc/systemd/system/ntpd.service
fi
