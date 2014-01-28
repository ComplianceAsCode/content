#
# Set runtime for net.ipv4.icmp_echo_ignore_broadcasts
#
sysctl -q -n -w net.ipv4.icmp_echo_ignore_broadcasts=1

#
# If net.ipv4.icmp_echo_ignore_broadcasts present in /etc/sysctl.conf, change value to "1"
#	else, add "net.ipv4.icmp_echo_ignore_broadcasts = 1" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.icmp_echo_ignore_broadcasts /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.icmp_echo_ignore_broadcasts.*/net.ipv4.icmp_echo_ignore_broadcasts = 1/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.icmp_echo_ignore_broadcasts to 1 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
fi
