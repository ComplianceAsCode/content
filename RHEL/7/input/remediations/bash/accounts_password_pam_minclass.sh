# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_minclass

if egrep -q ^minclass[[:space:]]*=[[:space:]]*[[:digit:]]+ /etc/security/pwquality.conf; then
	sed -i "s/^\(minclass *= *\).*/\1$var_password_pam_minclass/" /etc/security/pwquality.conf
else
	sed -i "/\(minclass *= *\).*/a minclass = $var_password_pam_minclass" /etc/security/pwquality.conf
fi
