# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate sysctl_net_ipv4_tcp_syncookies_value

#
# Set runtime for net.ipv4.tcp_syncookies
#
/sbin/sysctl -q -n -w net.ipv4.tcp_syncookies=$sysctl_net_ipv4_tcp_syncookies_value

#
# If net.ipv4.tcp_syncookies present in /etc/sysctl.conf, change value to appropriate value
#	else, add "net.ipv4.tcp_syncookies = value" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.tcp_syncookies /etc/sysctl.conf ; then
	sed -i "s/^net.ipv4.tcp_syncookies.*/net.ipv4.tcp_syncookies = $sysctl_net_ipv4_tcp_syncookies_value/g" /etc/sysctl.conf
else
	echo -e "\n# Set net.ipv4.tcp_syncookies to $sysctl_net_ipv4_tcp_syncookies_value per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_syncookies = $sysctl_net_ipv4_tcp_syncookies_value" >> /etc/sysctl.conf
fi
