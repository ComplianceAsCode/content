# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_ocredit

if grep -q "ocredit=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlinks "s/\(ocredit *= *\).*/\1$var_password_pam_ocredit/" /etc/pam.d/system-auth
else
	sed -i --follow-symlinks "/pam_cracklib.so/ s/$/ ocredit=$var_password_pam_ocredit/" /etc/pam.d/system-auth
fi
