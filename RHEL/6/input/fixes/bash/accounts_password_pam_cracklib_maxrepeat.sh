source ./templates/support.sh
populate var_password_pam_maxrepeat

if grep -q "maxrepeat=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlink "s/\(maxrepeat *= *\).*/\1$var_password_pam_maxrepeat/" /etc/pam.d/system-auth
else
	sed -i --follow-symlink "/pam_cracklib.so/ s/$/ maxrepeat=$var_password_pam_maxrepeat/" /etc/pam.d/system-auth
fi
