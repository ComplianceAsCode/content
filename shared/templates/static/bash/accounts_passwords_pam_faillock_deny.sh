# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_passwords_pam_faillock_deny

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
	
	# pam_faillock.so already present?
	if grep -q "^auth.*pam_faillock.so.*" $pamFile; then

		# pam_faillock.so present, deny directive present?
		if grep -q "^auth.*[default=die].*pam_faillock.so.*authfail.*deny=" $pamFile; then

			# both pam_faillock.so & deny present, just correct deny directive value
			sed -i --follow-symlinks "s/\(^auth.*required.*pam_faillock.so.*preauth.*silent.*\)\(deny *= *\).*/\1\2$var_accounts_passwords_pam_faillock_deny/" $pamFile
			sed -i --follow-symlinks "s/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\(deny *= *\).*/\1\2$var_accounts_passwords_pam_faillock_deny/" $pamFile

		# pam_faillock.so present, but deny directive not yet
		else

			# append correct deny value to appropriate places
			sed -i --follow-symlinks "/^auth.*required.*pam_faillock.so.*preauth.*silent.*/ s/$/ deny=$var_accounts_passwords_pam_faillock_deny/" $pamFile
			sed -i --follow-symlinks "/^auth.*[default=die].*pam_faillock.so.*authfail.*/ s/$/ deny=$var_accounts_passwords_pam_faillock_deny/" $pamFile
		fi

	# pam_faillock.so not present yet
	else

		# insert pam_faillock.so preauth & authfail rows with proper value of the 'deny' option
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent deny=$var_accounts_passwords_pam_faillock_deny" $pamFile
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail deny=$var_accounts_passwords_pam_faillock_deny" $pamFile
		sed -i --follow-symlinks "/^account.*required.*pam_unix.so/i account     required      pam_faillock.so" $pamFile
	fi
done
