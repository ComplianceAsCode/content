source ./templates/support.sh
populate var_password_pam_retry

if grep -q "retry=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlink "s/\(retry *= *\).*/\1$var_password_pam_retry/" /etc/pam.d/system-auth
else
	sed -i --follow-symlink "/pam_pwquality.so/ s/$/ retry=$var_password_pam_retry/" /etc/pam.d/system-auth
fi
