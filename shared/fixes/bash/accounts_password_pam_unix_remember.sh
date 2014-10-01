source ./templates/support.sh
populate var_password_pam_unix_remember

if grep -q "remember=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlink "s/\(remember *= *\).*/\1$var_password_pam_unix_remember/" /etc/pam.d/system-auth
else
	sed -i --follow-symlink "/^password[[:space:]]\+sufficient[[:space:]]\+pam_unix.so/ s/$/ remember=$var_password_pam_unix_remember/" /etc/pam.d/system-auth
fi
