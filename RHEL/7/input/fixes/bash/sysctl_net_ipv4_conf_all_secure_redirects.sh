#
# Set runtime for net.ipv4.conf.all.secure_redirects
#
sysctl -q -n -w net.ipv4.conf.all.secure_redirects=0

#
# If net.ipv4.conf.all.secure_redirects present in /etc/sysctl.conf, change value to "0"
#	else, add "net.ipv4.conf.all.secure_redirects = 0" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.conf.all.secure_redirects /etc/sysctl.conf ; then
	sed -i 's/^net.ipv4.conf.all.secure_redirects.*/net.ipv4.conf.all.secure_redirects = 0/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set net.ipv4.conf.all.secure_redirects to 0 per security requirements" >> /etc/sysctl.conf
	echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.conf
fi
