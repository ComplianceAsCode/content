#
# Set runtime for kernel.exec-shield
#
sysctl -q -n -w kernel.exec-shield=1

#
# If kernel.exec-shield present in /etc/sysctl.conf, change value to "1"
#	else, add "kernel.exec-shield = 1" to /etc/sysctl.conf
#
if grep --silent ^kernel.exec-shield /etc/sysctl.conf ; then
	sed -i 's/^kernel.exec-shield.*/kernel.exec-shield = 1/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set kernel.exec-shield to 1 per security requirements" >> /etc/sysctl.conf
	echo "kernel.exec-shield = 1" >> /etc/sysctl.conf
fi
