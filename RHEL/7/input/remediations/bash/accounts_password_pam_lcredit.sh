# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_lcredit

if egrep -q ^lcredit[[:space:]]*=[[:space:]]*[-]?[[:digit:]]+ /etc/security/pwquality.conf; then
	sed -i "s/^\(lcredit *= *\).*/\1$var_password_pam_lcredit/" /etc/security/pwquality.conf
else
	sed -i "/\(lcredit *= *\).*/a lcredit = $var_password_pam_lcredit" /etc/security/pwquality.conf
fi
