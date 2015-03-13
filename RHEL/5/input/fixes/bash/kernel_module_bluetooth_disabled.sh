if [ -d /etc/modprobe.d/ ]; then
	echo "install bluetooth /bin/true" >> /etc/modprobe.d/disabled_modules.conf
else
	echo "install bluetooth /bin/true" >> /etc/modprobe.conf
fi
