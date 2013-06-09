#
# Set runtime for net.ipv4.icmp_ignore_bogus_error_responses
#
sysctl -q -n -w net.ipv4.icmp_ignore_bogus_error_responses=1

#
# If net.ipv4.icmp_ignore_bogus_error_responses present in /etc/sysctl.conf, change value to "1"
#	else, add "net.ipv4.icmp_ignore_bogus_error_responses = 1" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.icmp_ignore_bogus_error_responses /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.icmp_ignore_bogus_error_responses.*/net.ipv4.icmp_ignore_bogus_error_responses = 1/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.icmp_ignore_bogus_error_responses to 1 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf
fi
