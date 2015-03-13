if [ -d /etc/modprobe.d/ ]; then
	echo "install appletalk /bin/true" >> /etc/modprobe.d/disabled_modules.conf
else
	echo "install appletalk /bin/true" >> /etc/modprobe.conf
fi
