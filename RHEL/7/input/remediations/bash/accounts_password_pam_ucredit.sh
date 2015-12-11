# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_ucredit

if egrep -q ^ucredit[[:space:]]*=[[:space:]]*[-]?[[:digit:]]+ /etc/security/pwquality.conf; then
	sed -i "s/^\(ucredit *= *\).*/\1$var_password_pam_ucredit/" /etc/security/pwquality.conf
else
	sed -i "/\(ucredit *= *\).*/a ucredit = $var_password_pam_ucredit" /etc/security/pwquality.conf
fi
