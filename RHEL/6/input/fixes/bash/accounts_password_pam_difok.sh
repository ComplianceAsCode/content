source ./templates/support.sh
populate var_password_pam_difok

if grep -q "difok=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlink "s/\(difok *= *\).*/\1$var_password_pam_difok/" /etc/pam.d/system-auth
else
	sed -i --follow-symlink "/pam_cracklib.so/ s/$/ difok=$var_password_pam_difok/" /etc/pam.d/system-auth
fi
