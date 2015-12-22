# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value

#
# Set runtime for net.ipv4.icmp_echo_ignore_broadcasts
#
/sbin/sysctl -q -n -w net.ipv4.icmp_echo_ignore_broadcasts=$sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value

#
# If net.ipv4.icmp_echo_ignore_broadcasts present in /etc/sysctl.conf, change value to appropriate value
#	else, add "net.ipv4.icmp_echo_ignore_broadcasts = value" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.icmp_echo_ignore_broadcasts /etc/sysctl.conf ; then
	sed -i "s/^net.ipv4.icmp_echo_ignore_broadcasts.*/net.ipv4.icmp_echo_ignore_broadcasts = $sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value/g" /etc/sysctl.conf
else
	echo -e "\n# Set net.ipv4.icmp_echo_ignore_broadcasts to $sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.icmp_echo_ignore_broadcasts = $sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value" >> /etc/sysctl.conf
fi
