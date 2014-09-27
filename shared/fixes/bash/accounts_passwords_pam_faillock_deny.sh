source ./templates/support.sh
populate var_accounts_passwords_pam_faillock_deny

if grep -q "deny=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlink "s/\(deny *= *\).*/\1$var_accounts_passwords_pam_faillock_deny/" /etc/pam.d/system-auth
else
	sed -i --follow-symlink "/pam_faillock.so/ s/$/ deny=$var_accounts_passwords_pam_faillock_deny/" /etc/pam.d/system-auth
fi

if grep -q "deny=" /etc/pam.d/password-auth; then   
	sed -i --follow-symlink "s/\(deny *= *\).*/\1$var_accounts_passwords_pam_faillock_deny/" /etc/pam.d/password-auth
else
	sed -i --follow-symlink "/pam_faillock.so/ s/$/ deny=$var_accounts_passwords_pam_faillock_deny/" /etc/pam.d/password-auth
fi
