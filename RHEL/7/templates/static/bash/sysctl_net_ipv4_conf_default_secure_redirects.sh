# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate sysctl_net_ipv4_conf_default_secure_redirects_value

#
# Set runtime for net.ipv4.conf.default.secure_redirects
#
/sbin/sysctl -q -n -w net.ipv4.conf.default.secure_redirects=$sysctl_net_ipv4_conf_default_secure_redirects_value

#
# If net.ipv4.conf.default.secure_redirects present in /etc/sysctl.conf, change value to appropriate value
#	else, add "net.ipv4.conf.default.secure_redirects = value" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.conf.default.secure_redirects /etc/sysctl.conf ; then
	sed -i "s/^net.ipv4.conf.default.secure_redirects.*/net.ipv4.conf.default.secure_redirects = $sysctl_net_ipv4_conf_default_secure_redirects_value/g" /etc/sysctl.conf
else
	echo -e "\n# Set net.ipv4.conf.default.secure_redirects to $sysctl_net_ipv4_conf_default_secure_redirects_value per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.default.secure_redirects = $sysctl_net_ipv4_conf_default_secure_redirects_value" >> /etc/sysctl.conf
fi
