if [ -d /etc/modprobe.d/ ]; then
	echo "install dccp /bin/true" >> /etc/modprobe.d/disabled_modules.conf
	echo "install dccp_ipv4 /bin/true" >> /etc/modprobe.d/disabled_modules.conf
	echo "install dccp_ipv6 /bin/true" >> /etc/modprobe.d/disabled_modules.conf
else
	echo "install dccp /bin/true" >> /etc/modprobe.conf
	echo "install dccp_ipv4 /bin/true" >> /etc/modprobe.conf
	echo "install dccp_ipv6 /bin/true" >> /etc/modprobe.conf
fi
