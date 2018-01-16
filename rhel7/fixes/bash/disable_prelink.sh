# platform = Red Hat Enterprise Linux 7

if rpm --quiet -q prelink; then
	if grep -q ^PRELINKING /etc/sysconfig/prelink
	then
		sed -i 's/PRELINKING.*/PRELINKING=no/g' /etc/sysconfig/prelink
	else
		echo -e '\n# Set PRELINKING=no per security requirements' >> /etc/sysconfig/prelink
		echo 'PRELINKING=no' >> /etc/sysconfig/prelink
	fi
	/usr/sbin/prelink -ua
fi
