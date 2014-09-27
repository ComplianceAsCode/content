source ./templates/support.sh
populate var_accounts_passwords_pam_faillock_deny

for pamFile in "/etc/pam.d/system-auth /etc/pam.d/password-auth"
do

	if grep -q "^auth.*[default=die].*pam_faillock.so.*authfail.*deny=" $pamFile; then
		sed -i --follow-symlink "s/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\(deny *= *\).*/\1\2$var_accounts_passwords_pam_faillock_deny/" $pamFile
	else
		sed -i --follow-symlink "/^auth.*[default=die].*pam_faillock.so.*authfail/ s/$/ deny=$var_accounts_passwords_pam_faillock_deny/" $pamFile
	fi
	
	if grep -q "^auth.*[default=die].*pam_faillock.so.*authsucc.*deny=" /etc/pam.d/system-auth; then
	        sed -i --follow-symlink "s/\(^auth.*[default=die].*pam_faillock.so.*authsucc.*\)\(deny *= *\).*/\1\2$var_accounts_passwords_pam_faillock_deny/" $pamFile
	else
	        sed -i --follow-symlink "/^auth.*[default=die].*pam_faillock.so.*authsucc/ s/$/ deny=$var_accounts_passwords_pam_faillock_deny/" $pamFile
	fi
done
