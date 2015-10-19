#
# Set runtime for net.ipv4.tcp_max_syn_backlog
#
/sbin/sysctl -q -n -w net.ipv4.tcp_max_syn_backlog=1280

#
# If net.ipv4.tcp_max_syn_backlog present in /etc/sysctl.conf, change value to "1280"
#	else, add "net.ipv4.tcp_max_syn_backlog = 1280" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.tcp_max_syn_backlog /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.tcp_max_syn_backlog.*/net.ipv4.tcp_max_syn_backlog = 1280/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.tcp_max_syn_backlog to 1 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_max_syn_backlog = 1280" >> /etc/sysctl.conf
fi
