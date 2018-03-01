# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_passwords_pam_faillock_unlock_time

# Invoke the function without args, so its body is substituded right here.
substitute_in_pam_file

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
    # 'true &&' has to be there due to build system limitation
    true && substitute_in_pam_file "$pamFile" unlock_time "$var_accounts_passwords_pam_faillock_unlock_time"
done
