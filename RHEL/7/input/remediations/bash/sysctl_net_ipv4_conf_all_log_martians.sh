# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate sysctl_net_ipv4_conf_all_log_martians_value

#
# Set runtime for net.ipv4.conf.all.log_martians
#
/sbin/sysctl -q -n -w net.ipv4.conf.all.log_martians=$sysctl_net_ipv4_conf_all_log_martians_value

#
# If net.ipv4.conf.all.log_martians present in /etc/sysctl.conf, change value to appropriate value
#	else, add "net.ipv4.conf.all.log_martians = value" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.conf.all.log_martians /etc/sysctl.conf ; then
	sed -i "s/^net.ipv4.conf.all.log_martians.*/net.ipv4.conf.all.log_martians = $sysctl_net_ipv4_conf_all_log_martians_value/g" /etc/sysctl.conf
else
	echo -e "\n# Set net.ipv4.conf.all.log_martians to $sysctl_net_ipv4_conf_all_log_martians_value per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.all.log_martians = $sysctl_net_ipv4_conf_all_log_martians_value" >> /etc/sysctl.conf
fi
