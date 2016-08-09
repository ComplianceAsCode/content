. /usr/share/scap-security-guide/remediation_functions
populate ftp_login_banner_text

if [ -e /etc/xinetd.d/gssftp ]; then
	if [ "`egrep -c '^(\s|\t)banner' /etc/xinetd.d/gssftp`" = "0" ]; then
		sed -i "/^}$/i\\\tbanner\t\t= /etc/issue" /etc/xinetd.d/gssftp
	else
		GSSFTP_BANNER_FILE="`egrep '^(\s|\t)banner' /etc/xinetd.d/gssftp | awk '{ print $3 }'`"
		echo $ftp_login_banner_text | sed -e 's/\[\\s\\n\][+|*]/ /g' -e 's/\&amp;/\&/g' -e 's/\\//g' -e 's/ - /\n- /g' >"${GSSFTP_BANNER_FILE}"
	fi
fi

if [ -e /etc/vsftpd/vsftpd.conf ]; then
	if [ "`egrep -c '^banner_file' /etc/vsftpd/vsftpd.conf`" = "0" ]; then
		echo "banner_file=/etc/issue" >> /etc/vsftpd/vsftpd.conf
	else
		VSFTPD_BANNER_FILE="`egrep '^banner_file' /etc/vsftpd/vsftpd.conf | awk -F= '{ print $2 }'`"
		echo $ftp_login_banner_text | sed -e 's/\[\\s\\n\][+|*]/ /g' -e 's/\&amp;/\&/g' -e 's/\\//g' -e 's/ - /\n- /g' >"${VSFTPD_BANNER_FILE}"
	fi
fi
