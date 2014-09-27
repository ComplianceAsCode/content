source ./templates/support.sh
populate var_password_pam_lcredit

if grep -q "lcredit=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlink "s/\(lcredit *= *\).*/\1$var_password_pam_lcredit/" /etc/pam.d/system-auth
else
	sed -i --follow-symlink "/pam_cracklib.so/ s/$/ lcredit=$var_password_pam_lcredit/" /etc/pam.d/system-auth
fi
