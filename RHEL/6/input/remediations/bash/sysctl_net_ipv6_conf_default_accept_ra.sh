# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate sysctl_net_ipv6_conf_default_accept_ra_value

#
# Set runtime for net.ipv6.conf.default.accept_ra
#
/sbin/sysctl -q -n -w net.ipv6.conf.default.accept_ra=$sysctl_net_ipv6_conf_default_accept_ra_value

#
# If net.ipv6.conf.default.accept_ra present in /etc/sysctl.conf, change value to appropriate value
#	else, add "net.ipv6.conf.default.accept_ra = value" to /etc/sysctl.conf
#
if grep --silent ^net.ipv6.conf.default.accept_ra /etc/sysctl.conf ; then
	sed -i "s/^net.ipv6.conf.default.accept_ra.*/net.ipv6.conf.default.accept_ra = $sysctl_net_ipv6_conf_default_accept_ra_value/g" /etc/sysctl.conf
else
	echo -e "\n# Set net.ipv6.conf.default.accept_ra to $sysctl_net_ipv6_conf_default_accept_ra_value per security requirements" >> /etc/sysctl.conf
	echo "net.ipv6.conf.default.accept_ra = $sysctl_net_ipv6_conf_default_accept_ra_value" >> /etc/sysctl.conf
fi
