#
# Set runtime for net.ipv4.conf.default.rp_filter
#
/sbin/sysctl -q -n -w net.ipv4.conf.default.rp_filter=1

#
# If net.ipv4.conf.default.rp_filter present in /etc/sysctl.conf, change value to "1"
#	else, add "net.ipv4.conf.default.rp_filter = 1" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.conf.default.rp_filter /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.conf.default.rp_filter.*/net.ipv4.conf.default.rp_filter = 1/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.conf.default.rp_filter to 1 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf
fi
