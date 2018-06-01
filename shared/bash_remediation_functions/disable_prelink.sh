function disable_prelink {
	# Disable prelinking and don't even check
	# whether it is installed.
	if grep -q ^PRELINKING /etc/sysconfig/prelink
	then
		sed -i 's/PRELINKING.*/PRELINKING=no/g' /etc/sysconfig/prelink
	else
		printf '\n%s\n' '# Set PRELINKING=no per security requirements' >> /etc/sysconfig/prelink
		echo 'PRELINKING=no' >> /etc/sysconfig/prelink
	fi

	# Undo previous prelink changes to binaries if prelink is available.
	if test -x /usr/sbin/prelink; then
		/usr/sbin/prelink -ua
	fi
}
