SYS_USER=$(cat /etc/passwd | while read entry; do if [ "$(echo ${entry} | cut -d: -f3)" -lt "500" ]; then echo ${entry} | cut -d: -f1 ; fi; done)
if [ "$(rpm -q krb5-workstation &>/dev/null; echo $?)" = "0" ]; then
	if [ ! -e /etc/ftpusers ]; then
		>/etc/ftpusers
		chmod 0640 /etc/ftpusers
		chown root:root /etc/ftpusers
	fi
	for USER in `echo $SYS_USER`; do
		if [ $(grep -c "^${USER}$" /etc/ftpusers) = 0 ]; then
			echo ${USER} | tee -a /etc/ftpusers &>/dev/null
		fi
	done
fi
if [ "$(rpm -q vsftpd &>/dev/null; echo $?)" = "0" ]; then
	if [ ! -e /etc/vsftpd/ftpusers ]; then
		>/etc/vsftpd/ftpusers
		chmod 0640 /etc/vsftpd/ftpusers
		chown root:root /etc/vsftpd/ftpusers
	fi
	for USER in `echo $SYS_USER`; do
		if [ $(grep -c "^${USER}$" /etc/vsftpd/ftpusers) = 0 ]; then
			echo ${USER} | tee -a /etc/vsftpd/ftpusers &>/dev/null
		fi
	done
fi
