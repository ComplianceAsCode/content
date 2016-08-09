if [ -d /etc/modprobe.d/ ]; then
	echo "install ipv6 /bin/true" >> /etc/modprobe.d/disabled_modules.conf
else
	echo "install ipv6 /bin/true" >> /etc/modprobe.conf
fi
chkconfig ip6tables off
