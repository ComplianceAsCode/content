# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_maxclassrepeat

if grep -q "maxclassrepeat=" /etc/security/pwquality.conf ; then   
	echo "maxclassrepeat = $var_password_pam_maxclassrepeat" >> /etc/security/pwquality.conf
fi