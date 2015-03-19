if [[ "`uname -r`" != "2.6.9"* ]]; then
	/sbin/sysctl -q -n -w kernel.randomize_va_space=1
	if grep --silent ^kernel.randomize_va_space /etc/sysctl.conf ; then
		sed -i 's/^kernel.randomize_va_space.*/kernel.randomize_va_space = 1/g' /etc/sysctl.conf
	else
		echo "" >> /etc/sysctl.conf
		echo "# Set kernel.randomize_va_space to 1 per security requirements" >> /etc/sysctl.conf
		echo "kernel.randomize_va_space = 1" >> /etc/sysctl.conf
	fi
fi

/sbin/sysctl -q -n -w kernel.exec-shield=1
if grep --silent ^kernel.exec-shield /etc/sysctl.conf ; then
	sed -i 's/^kernel.exec-shield.*/kernel.exec-shield = 1/g' /etc/sysctl.conf
else
	echo "" >> /etc/sysctl.conf
	echo "# Set kernel.exec-shield to 1 per security requirements" >> /etc/sysctl.conf
	echo "kernel.exec-shield = 1" >> /etc/sysctl.conf
fi
