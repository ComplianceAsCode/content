# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate sysctl_net_ipv4_conf_default_accept_source_route_value

#
# Set runtime for net.ipv4.conf.default.accept_source_route
#
/sbin/sysctl -q -n -w net.ipv4.conf.default.accept_source_route=$sysctl_net_ipv4_conf_default_accept_source_route_value

#
# If net.ipv4.conf.default.accept_source_route present in /etc/sysctl.conf, change value to appropriate value
#	else, add "net.ipv4.conf.default.accept_source_route = value" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.conf.default.accept_source_route /etc/sysctl.conf ; then
	sed -i "s/^net.ipv4.conf.default.accept_source_route.*/net.ipv4.conf.default.accept_source_route = $sysctl_net_ipv4_conf_default_accept_source_route_value/g" /etc/sysctl.conf
else
	echo -e "\n# Set net.ipv4.conf.default.accept_source_route to $sysctl_net_ipv4_conf_default_accept_source_route_value per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.default.accept_source_route = $sysctl_net_ipv4_conf_default_accept_source_route_value" >> /etc/sysctl.conf
fi
