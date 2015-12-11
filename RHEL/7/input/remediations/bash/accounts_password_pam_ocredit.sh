# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_ocredit

if egrep -q ^ocredit[[:space:]]*=[[:space:]]*[-]?[[:digit:]]+ /etc/security/pwquality.conf; then
	sed -i "s/^\(ocredit *= *\).*/\1$var_password_pam_ocredit/" /etc/security/pwquality.conf
else
	sed -i "/\(ocredit *= *\).*/a ocredit = $var_password_pam_ocredit" /etc/security/pwquality.conf
fi
