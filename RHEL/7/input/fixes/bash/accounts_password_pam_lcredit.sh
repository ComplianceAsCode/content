source ./templates/support.sh
populate var_password_pam_lcredit

if egrep -q ^lcredit[[:space:]]*=[[:space:]]*[-]?[[:digit:]]+ /etc/security/pwquality.conf; then
	sed -i "s/^\(lcredit *= *\).*/\1$var_password_pam_lcredit/" /etc/security/pwquality.conf
else
	sed -i "/\(lcredit *= *\).*/a lcredit = $var_password_pam_lcredit" /etc/security/pwquality.conf
fi
