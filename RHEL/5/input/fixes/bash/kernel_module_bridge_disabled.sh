if [ -d /etc/modprobe.d/ ]; then
	echo "install bridge /bin/true" >> /etc/modprobe.d/disabled_modules.conf
else
	echo "install bridge /bin/true" >> /etc/modprobe.conf
fi
