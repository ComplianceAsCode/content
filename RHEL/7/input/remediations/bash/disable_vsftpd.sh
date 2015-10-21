# platform = Red Hat Enterprise Linux 7
if service vsftpd status >/dev/null; then
	service vsftpd stop
fi
