# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate sysctl_net_ipv4_icmp_ignore_bogus_error_responses_value

#
# Set runtime for net.ipv4.icmp_ignore_bogus_error_responses
#
/sbin/sysctl -q -n -w net.ipv4.icmp_ignore_bogus_error_responses=$sysctl_net_ipv4_icmp_ignore_bogus_error_responses_value

#
# If net.ipv4.icmp_ignore_bogus_error_responses present in /etc/sysctl.conf, change value to appropriate value
#	else, add "net.ipv4.icmp_ignore_bogus_error_responses = value" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.icmp_ignore_bogus_error_responses /etc/sysctl.conf ; then
	sed -i "s/^net.ipv4.icmp_ignore_bogus_error_responses.*/net.ipv4.icmp_ignore_bogus_error_responses = $sysctl_net_ipv4_icmp_ignore_bogus_error_responses_value/g" /etc/sysctl.conf
else
	echo -e "\n# Set net.ipv4.icmp_ignore_bogus_error_responses to $sysctl_net_ipv4_icmp_ignore_bogus_error_responses_value per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.icmp_ignore_bogus_error_responses = $sysctl_net_ipv4_icmp_ignore_bogus_error_responses_value" >> /etc/sysctl.conf
fi
