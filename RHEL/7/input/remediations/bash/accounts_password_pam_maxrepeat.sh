# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_maxrepeat

if egrep -q ^maxrepeat[[:space:]]*=[[:space:]]*[[:digit:]]+ /etc/security/pwquality.conf; then
	sed -i "s/^\(maxrepeat *= *\).*/\1$var_password_pam_maxrepeat/" /etc/security/pwquality.conf
else
	sed -i "/\(maxrepeat *= *\).*/a maxrepeat = $var_password_pam_maxrepeat" /etc/security/pwquality.conf
fi
