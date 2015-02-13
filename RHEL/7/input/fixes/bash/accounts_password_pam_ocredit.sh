source ./templates/support.sh
populate var_password_pam_ocredit

if egrep -q ^ocredit[[:space:]]*=[[:space:]]*[-]?[[:digit:]]+ /etc/security/pwquality.conf; then
	sed -i "s/^\(ocredit *= *\).*/\1$var_password_pam_ocredit/" /etc/security/pwquality.conf
else
	sed -i "/\(ocredit *= *\).*/a ocredit = $var_password_pam_ocredit" /etc/security/pwquality.conf
fi
