/sbin/sysctl -q -n -w net.ipv4.conf.all.send_redirects=0
/sbin/sysctl -q -n -w net.ipv4.conf.default.send_redirects=0

if grep --silent ^net.ipv4.conf.all.send_redirects /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.conf.all.send_redirects.*/net.ipv4.conf.all.send_redirects = 0/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.conf.all.send_redirects to 0 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
fi

if grep --silent ^net.ipv4.conf.default.send_redirects /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.conf.default.send_redirects.*/net.ipv4.conf.default.send_redirects = 0/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.conf.default.send_redirects to 0 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
fi
