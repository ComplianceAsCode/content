#
# Set runtime for net.ipv6.conf.default.accept_ra
#
/sbin/sysctl -q -n -w net.ipv6.conf.default.accept_ra=0

#
# If net.ipv6.conf.default.accept_ra present in /etc/sysctl.conf, change value to "0"
#	else, add "net.ipv6.conf.default.accept_ra = 0" to /etc/sysctl.conf
#
if grep --silent ^net.ipv6.conf.default.accept_ra /etc/sysctl.conf ; then
	sed -i 's/^net.ipv6.conf.default.accept_ra.*/net.ipv6.conf.default.accept_ra = 0/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv6.conf.default.accept_ra to 0 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv6.conf.default.accept_ra = 0" >> /etc/sysctl.conf
fi
