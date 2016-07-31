# platform = Red Hat Enterprise Linux 7
#
# Set runtime for net.ipv6.conf.all.disable_ipv6
#
/sbin/sysctl -q -n -w net.ipv6.conf.all.disable_ipv6=1

#
# If net.ipv6.conf.all.disable_ipv6 present in /etc/sysctl.conf, change value to "1"
#	else, add "net.ipv6.conf.all.disable_ipv6 = 1" to /etc/sysctl.conf
#
if grep --silent ^net.ipv6.conf.all.disable_ipv6 /etc/sysctl.conf ; then
	sed -i 's/^net.ipv6.conf.all.disable_ipv6.*/net.ipv6.conf.all.disable_ipv6 = 1/g' /etc/sysctl.conf
else
	echo -e "\n# Set net.ipv6.conf.all.disable_ipv6 to 1 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
fi
