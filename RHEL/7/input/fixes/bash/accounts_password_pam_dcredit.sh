source ./templates/support.sh
populate var_password_pam_dcredit

if egrep -q ^dcredit[[:space:]]*=[[:space:]]*[-]?[[:digit:]]+ /etc/security/pwquality.conf; then
	sed -i "s/^\(dcredit *= *\).*/\1$var_password_pam_dcredit/" /etc/security/pwquality.conf
else
	sed -i "/\(dcredit *= *\).*/a dcredit = $var_password_pam_dcredit" /etc/security/pwquality.conf
fi
