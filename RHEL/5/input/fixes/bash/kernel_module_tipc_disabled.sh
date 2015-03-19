if [ -d /etc/modprobe.d/ ]; then
	echo "install tipc /bin/true" >> /etc/modprobe.d/disabled_modules.conf
else
	echo "install tipc /bin/true" >> /etc/modprobe.conf
fi
