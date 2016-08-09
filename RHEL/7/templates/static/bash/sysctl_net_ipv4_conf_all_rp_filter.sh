# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate sysctl_net_ipv4_conf_all_rp_filter_value

#
# Set runtime for net.ipv4.conf.all.rp_filter
#
/sbin/sysctl -q -n -w net.ipv4.conf.all.rp_filter=$sysctl_net_ipv4_conf_all_rp_filter_value

#
# If net.ipv4.conf.all.rp_filter present in /etc/sysctl.conf, change value to appropriate value
#	else, add "net.ipv4.conf.all.rp_filter = value" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.conf.all.rp_filter /etc/sysctl.conf ; then
	sed -i "s/^net.ipv4.conf.all.rp_filter.*/net.ipv4.conf.all.rp_filter = $sysctl_net_ipv4_conf_all_rp_filter_value/g" /etc/sysctl.conf
else
	echo -e "\n# Set net.ipv4.conf.all.rp_filter to $sysctl_net_ipv4_conf_all_rp_filter_value per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.all.rp_filter = $sysctl_net_ipv4_conf_all_rp_filter_value" >> /etc/sysctl.conf
fi
