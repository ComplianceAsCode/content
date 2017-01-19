# platform = Red Hat Enterprise Linux 6
. $SHARED_REMEDIATION_FUNCTIONS
populate var_password_pam_lcredit

if grep -q "lcredit=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlinks "s/\(lcredit *= *\).*/\1$var_password_pam_lcredit/" /etc/pam.d/system-auth
else
	sed -i --follow-symlinks "/pam_cracklib.so/ s/$/ lcredit=$var_password_pam_lcredit/" /etc/pam.d/system-auth
fi
