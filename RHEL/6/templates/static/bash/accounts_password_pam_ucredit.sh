# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_ucredit

if grep -q "ucredit=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlinks "s/\(ucredit *= *\).*/\1$var_password_pam_ucredit/" /etc/pam.d/system-auth
else
	sed -i --follow-symlinks "/pam_cracklib.so/ s/$/ ucredit=$var_password_pam_ucredit/" /etc/pam.d/system-auth
fi
