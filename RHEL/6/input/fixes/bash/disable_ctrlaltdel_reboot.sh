if [ -f /etc/init/control-alt-delete.conf ]; then
	cp /etc/init/control-alt-delete.conf /etc/init/control-alt-delete.override
fi

sed -i 's,^exec.*,exec /usr/bin/logger -p authpriv.notice -t init "Ctrl-Alt-Del was pressed and ignored",' /etc/init/control-alt-delete.override
