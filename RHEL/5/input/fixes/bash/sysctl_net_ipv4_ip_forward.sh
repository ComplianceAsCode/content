#
# Set runtime for net.ipv4.ip_forward
#
/sbin/sysctl -q -n -w net.ipv4.ip_forward=0

#
# If net.ipv4.ip_forward present in /etc/sysctl.conf, change value to "0"
#	else, add "net.ipv4.ip_forward = 0" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.ip_forward /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.ip_forward.*/net.ipv4.ip_forward = 0/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.ip_forward to 0 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
fi
