/sbin/sysctl -q -n -w net.ipv4.conf.all.log_martians=1
/sbin/sysctl -q -n -w net.ipv4.conf.default.log_martians=1

if grep --silent ^net.ipv4.conf.all.log_martians /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.conf.all.log_martians.*/net.ipv4.conf.all.log_martians = 1/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.conf.all.log_martians to 1 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
fi

if grep --silent ^net.ipv4.conf.default.log_martians /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.conf.default.log_martians.*/net.ipv4.conf.default.log_martians = 1/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.conf.default.log_martians to 1 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf
fi
