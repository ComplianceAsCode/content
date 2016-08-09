if [ -d /etc/modprobe.d/ ]; then
	echo "install sctp /bin/true" >> /etc/modprobe.d/disabled_modules.conf
else
	echo "install sctp /bin/true" >> /etc/modprobe.conf
fi
