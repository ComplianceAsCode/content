if [ ! -e /var/log/btmp ]; then
	>/var/log/btmp
	chmod 600 /var/log/btmp
	chown root:root /var/log/btmp
fi
if [ ! -e /var/log/wtmp ]; then
	>/var/log/wtmp
	chmod 664 /var/log/wtmp
	chown root:root /var/log/wtmp
fi
