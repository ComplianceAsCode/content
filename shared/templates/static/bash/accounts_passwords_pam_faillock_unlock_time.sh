# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_passwords_pam_faillock_unlock_time

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
	
	# pam_faillock.so already present?
	if grep -q "^auth.*pam_faillock.so.*" $pamFile; then

		# pam_faillock.so present, unlock_time directive present?
		if grep -q "^auth.*[default=die].*pam_faillock.so.*authfail.*unlock_time=" $pamFile; then

			# both pam_faillock.so & unlock_time present, just correct unlock_time directive value
			sed -i --follow-symlinks "s/\(^auth.*required.*pam_faillock.so.*preauth.*silent.*\)\(unlock_time *= *\).*/\1\2$var_accounts_passwords_pam_faillock_unlock_time/" $pamFile
			sed -i --follow-symlinks "s/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\(unlock_time *= *\).*/\1\2$var_accounts_passwords_pam_faillock_unlock_time/" $pamFile

		# pam_faillock.so present, but unlock_time directive not yet
		else

			# append correct unlock_time value to appropriate places
			sed -i --follow-symlinks "/^auth.*required.*pam_faillock.so.*preauth.*silent.*/ s/$/ unlock_time=$var_accounts_passwords_pam_faillock_unlock_time/" $pamFile
			sed -i --follow-symlinks "/^auth.*[default=die].*pam_faillock.so.*authfail.*/ s/$/ unlock_time=$var_accounts_passwords_pam_faillock_unlock_time/" $pamFile
		fi

	# pam_faillock.so not present yet
	else

		# insert pam_faillock.so preauth & authfail rows with proper value of the 'unlock_time' option
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent unlock_time=$var_accounts_passwords_pam_faillock_unlock_time" $pamFile
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail unlock_time=$var_accounts_passwords_pam_faillock_unlock_time" $pamFile
		sed -i --follow-symlinks "/^account.*required.*pam_unix.so/i account     required      pam_faillock.so" $pamFile
	fi
done
