function disable_prelink {
	# prelink not installed
	if test ! -e /etc/sysconfig/prelink -a ! -e /usr/sbin/prelink; then
		return 0
	fi

	if grep -q ^PRELINKING /etc/sysconfig/prelink
	then
		sed -i 's/^PRELINKING[:blank:]*=[:blank:]*[:alpha:]*/PRELINKING=no/' /etc/sysconfig/prelink
	else
		printf '\n' >> /etc/sysconfig/prelink
		printf '%s\n' '# Set PRELINKING=no per security requirements' 'PRELINKING=no' >> /etc/sysconfig/prelink
	fi

	# Undo previous prelink changes to binaries if prelink is available.
	if test -x /usr/sbin/prelink; then
		/usr/sbin/prelink -ua
	fi
}
