if [ -d /etc/modprobe.d/ ]; then
	echo "install usb-storage /bin/true" >> /etc/modprobe.d/disabled_modules.conf
else
	echo "install usb-storage /bin/true" >> /etc/modprobe.conf
fi
