if [ "$(rpm -q krb5-workstation &>/dev/null; echo $?)" = "0" ]; then
	if [ "$(grep server_args /etc/xinetd.d/gssftp | grep -v "#" | grep -c "\-u 077")" = "0" ]; then
		sed -i '/server_args/s/$/ -u 077/' /etc/xinetd.d/gssftp
	fi
fi
if [ "$(rpm -q vsftpd &>/dev/null; echo $?)" = "0" ]; then
	if [ "$(grep -c local_umask /etc/vsftpd/vsftpd.conf)" = "0" ]; then
		echo "local_umask=077" >> /etc/vsftpd/vsftpd.conf
	else
		sed -i '/local_umask/s/=.*/=077/' /etc/vsftpd/vsftpd.conf
	fi
	if [ "$(grep -c anon_umask /etc/vsftpd/vsftpd.conf)" = "0" ]; then
		echo "anon_umask=077" >> /etc/vsftpd/vsftpd.conf
	else
		sed -i '/anon_umask/s/=.*/=077/' /etc/vsftpd/vsftpd.conf
	fi
fi
