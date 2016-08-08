#
# Set runtime for net.ipv6.conf.all.forwarding
#
if [ -e /proc/sys/net/ipv6/ ]; then
	/sbin/sysctl -q -n -w net.ipv6.conf.all.forwarding=0
fi

#
# If net.ipv6.conf.all.forwarding present in /etc/sysctl.conf, change value to "0"
#	else, add "net.ipv6.conf.all.forwarding = 0" to /etc/sysctl.conf
#
if grep --silent ^net.ipv6.conf.all.forwarding /etc/sysctl.conf ; then
	sed -i 's/^net.ipv6.conf.all.forwarding.*/net.ipv6.conf.all.forwarding = 0/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv6.conf.all.forwarding to 0 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.conf
fi

#
# Set runtime for net.ipv6.conf.default.forwarding
#
if [ -e /proc/sys/net/ipv6/ ]; then
	/sbin/sysctl -q -n -w net.ipv6.conf.default.forwarding=0
fi
#
# If net.ipv6.conf.default.forwarding present in /etc/sysctl.conf, change value to "0"
#	else, add "net.ipv6.conf.default.forwarding = 0" to /etc/sysctl.conf
#
if grep --silent ^net.ipv6.conf.default.forwarding /etc/sysctl.conf ; then
	sed -i 's/^net.ipv6.conf.default.forwarding.*/net.ipv6.conf.default.forwarding = 0/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv6.conf.default.forwarding to 0 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv6.conf.default.forwarding = 0" >> /etc/sysctl.conf
fi
