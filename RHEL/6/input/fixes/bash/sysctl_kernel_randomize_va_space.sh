#
# Set runtime for kernel.randomize_va_space
#
/sbin/sysctl -q -n -w kernel.randomize_va_space=2

#
# If kernel.randomize_va_space present in /etc/sysctl.conf, change value to "2"
#	else, add "kernel.randomize_va_space = 2" to /etc/sysctl.conf
#
if grep --silent ^kernel.randomize_va_space /etc/sysctl.conf ; then
	sed -i 's/^kernel.randomize_va_space.*/kernel.randomize_va_space = 2/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set kernel.randomize_va_space to 2 per security requirements" >> /etc/sysctl.conf
	echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf
fi
