if [ -d /etc/modprobe.d/ ]; then
	echo "install ieee1394 /bin/true" >> /etc/modprobe.d/disabled_modules.conf
else
	echo "install ieee1394 /bin/true" >> /etc/modprobe.conf
fi
