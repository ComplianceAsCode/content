# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_passwords_pam_faillock_fail_interval

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
	
	# pam_faillock.so already present?
	if grep -q "^auth.*pam_faillock.so.*" $pamFile; then

		# pam_faillock.so present, 'fail_interval' directive present?
		if grep -q "^auth.*[default=die].*pam_faillock.so.*authfail.*fail_interval=" $pamFile; then

			# both pam_faillock.so & 'fail_interval' present, just correct 'fail_interval' directive value
			sed -i --follow-symlinks "s/\(^auth.*required.*pam_faillock.so.*preauth.*silent.*\)\(fail_interval *= *\).*/\1\2$var_accounts_passwords_pam_faillock_fail_interval/" $pamFile
			sed -i --follow-symlinks "s/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\(fail_interval *= *\).*/\1\2$var_accounts_passwords_pam_faillock_fail_interval/" $pamFile

		# pam_faillock.so present, but 'fail_interval' directive not yet
		else

			# append correct 'fail_interval' value to appropriate places
			sed -i --follow-symlinks "/^auth.*required.*pam_faillock.so.*preauth.*silent.*/ s/$/ fail_interval=$var_accounts_passwords_pam_faillock_fail_interval/" $pamFile
			sed -i --follow-symlinks "/^auth.*[default=die].*pam_faillock.so.*authfail.*/ s/$/ fail_interval=$var_accounts_passwords_pam_faillock_fail_interval/" $pamFile
		fi

	# pam_faillock.so not present yet
	else

		# insert pam_faillock.so preauth & authfail rows with proper value of the 'fail_interval' option
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent fail_interval=$var_accounts_passwords_pam_faillock_fail_interval" $pamFile
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail fail_interval=$var_accounts_passwords_pam_faillock_fail_interval" $pamFile
		sed -i --follow-symlinks "/^account.*required.*pam_unix.so/i account     required      pam_faillock.so" $pamFile
	fi
done
