if [ -e /etc/xinetd.d/gssftp ]; then
	if [ "$(grep server_args /etc/xinetd.d/gssftp | grep -c " -l")" = "0" ]; then
		sed -i "/server_args/s/$/ -l/" /etc/xinetd.d/gssftp
	fi
fi
if [ -e /etc/vsftpd/vsftpd.conf ]; then
	if [ "$(grep -ic "^xferlog_enable=yes" /etc/vsftpd/vsftpd.conf)" = "0" ]; then
		sed -i "s/xferlog_enable.*/xferlog_enable=yes/" /etc/xinetd.d/gssftp
	fi
fi
