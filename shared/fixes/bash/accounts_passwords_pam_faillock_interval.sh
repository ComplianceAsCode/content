# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_passwords_pam_faillock_fail_interval

# substitute_in_pam_file

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
	substitute_in_pam_file "$pamFile" fail_interval "$var_accounts_passwords_pam_faillock_fail_interval"
done
