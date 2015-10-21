# platform = Red Hat Enterprise Linux 7
#
# Set runtime for kernel.dmesg_restrict
#
sysctl -q -n -w kernel.dmesg_restrict=1

#
# If kernel.dmesg_restrict present in /etc/sysctl.conf, change value to "1"
#	else, add "kernel.dmesg_restrict = 1" to /etc/sysctl.conf
#
if grep --silent ^kernel.dmesg_restrict /etc/sysctl.conf ; then
	sed -i 's/^kernel.dmesg_restrict.*/kernel.dmesg_restrict = 1/g' /etc/sysctl.conf
else
	echo -e "\n# Set kernel.dmesg_restrict to 1 per security requirements" >> /etc/sysctl.conf
	echo "kernel.dmesg_restrict = 1" >> /etc/sysctl.conf
fi
