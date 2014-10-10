#
# Set runtime for net.ipv4.conf.all.log_martians
#
/sbin/sysctl -q -n -w net.ipv4.conf.all.log_martians=1

#
# If net.ipv4.conf.all.log_martians present in /etc/sysctl.conf, change value to "1"
#	else, add "net.ipv4.conf.all.log_martians = 1" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.conf.all.log_martians /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.conf.all.log_martians.*/net.ipv4.conf.all.log_martians = 1/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.conf.all.log_martians to 1 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
fi
