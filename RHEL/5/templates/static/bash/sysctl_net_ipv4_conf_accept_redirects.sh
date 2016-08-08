/sbin/sysctl -q -n -w net.ipv4.conf.all.accept_redirects=0
/sbin/sysctl -q -n -w net.ipv4.conf.default.accept_redirects=0

if grep --silent ^net.ipv4.conf.all.accept_redirects /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.conf.all.accept_redirects.*/net.ipv4.conf.all.accept_redirects = 0/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.conf.all.accept_redirects to 0 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
fi

if grep --silent ^net.ipv4.conf.default.accept_redirects /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.conf.default.accept_redirects.*/net.ipv4.conf.default.accept_redirects = 0/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.conf.default.accept_redirects to 0 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
fi
