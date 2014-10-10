#
# Set runtime for fs.suid_dumpable
#
/sbin/sysctl -q -n -w fs.suid_dumpable=0

#
# If fs.suid_dumpable present in /etc/sysctl.conf, change value to "0"
#	else, add "fs.suid_dumpable = 0" to /etc/sysctl.conf
#
if grep --silent ^fs.suid_dumpable /etc/sysctl.conf ; then
	sed -i 's/^fs.suid_dumpable.*/fs.suid_dumpable = 0/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set fs.suid_dumpable to 0 per security requirements" >> /etc/sysctl.conf
	echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
fi
