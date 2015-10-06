# platform = Red Hat Enterprise Linux 6
if service vsftpd status >/dev/null; then
	service vsftpd stop
fi
