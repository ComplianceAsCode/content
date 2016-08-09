# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_maxrepeat

if grep -q "maxrepeat=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlinks "s/\(maxrepeat *= *\).*/\1$var_password_pam_maxrepeat/" /etc/pam.d/system-auth
else
	sed -i --follow-symlinks "/pam_cracklib.so/ s/$/ maxrepeat=$var_password_pam_maxrepeat/" /etc/pam.d/system-auth
fi
