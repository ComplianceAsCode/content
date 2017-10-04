# platform = Red Hat Enterprise Linux 6
# If system does not contain control-alt-delete.override,
if [ ! -f /etc/init/control-alt-delete.override ]; then

	# but does have control-alt-delete.conf file,
	if [ -f /etc/init/control-alt-delete.conf ]; then

		# then copy .conf to .override to maintain persistency
		cp /etc/init/control-alt-delete.conf /etc/init/control-alt-delete.override
	fi
fi
 
sed -i 's,^exec.*$,exec /usr/bin/logger -p authpriv.notice -t init "Ctrl-Alt-Del was pressed and ignored",' /etc/init/control-alt-delete.override
