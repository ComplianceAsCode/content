# platform = Red Hat Enterprise Linux 7
#
# Set runtime for SYSCTLVAR
#
/sbin/sysctl -q -n -w net.ipv6.conf.all.accept_source_route=0

#
# If SYSCTLVAR present in /etc/sysctl.conf, change value to "SYSCTLVAL"
#	else, add "SYSCTLVAR = SYSCTLVAL" to /etc/sysctl.conf
#
if grep --silent ^net.ipv6.conf.all.accept_source_route /etc/sysctl.conf ; then
	sed -i 's/^net.ipv6.conf.all.accept_source_route.*/net.ipv6.conf.all.accept_source_route = 0/g' /etc/sysctl.conf
else
	echo -e "\n# Set net.ipv6.conf.all.accept_source_route to 0 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
fi
