if [ -d /etc/modprobe.d/ ]; then
	echo "install rds /bin/true" >> /etc/modprobe.d/disabled_modules.conf
else
	echo "install rds /bin/true" >> /etc/modprobe.conf
fi
