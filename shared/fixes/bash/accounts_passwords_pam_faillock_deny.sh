# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_passwords_pam_faillock_deny

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

# This script fixes absence of pam_faillock.so in PAM stack or the
# absense of deny=[0-9]+ in pam_faillock.so arguments
# When inserting auth pam_faillock.so entries,
# the entry with preauth argument will be added before pam_unix.so module
# and entry with authfail argument will be added before pam_deny.so module.

# The placement of pam_faillock.so entries will not be changed
# if they are already present


# Invoke the function without args, so its body is substituded right here.
set_faillock_option_to_value_in_pam_file


function insert_lines_if_pam_faillock_so_not_present {
	# insert pam_faillock.so preauth row with proper value of the 'deny' option before pam_unix.so
	sed -i --follow-symlinks "/^auth.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent $_option=$_value" $_pamFile
	# insert pam_faillock.so authfail row with proper value of the 'deny' option before pam_deny.so, after all modules which determine authentication outcome.
	sed -i --follow-symlinks "/^auth.*pam_deny.so.*/i auth        [default=die] pam_faillock.so authfail $_option=$_value" $_pamFile
}



for pamFile in "${AUTH_FILES[@]}"
do
	# 'true &&' has to be there due to build system limitation
	true && set_faillock_option_to_value_in_pam_file "$pamFile" fail_interval "$var_accounts_passwords_pam_faillock_fail_interval" insert_lines_if_pam_faillock_so_not_present

	# add pam_faillock.so into account phase
	if ! grep -q "^account.*required.*pam_faillock.so" $pamFile; then
		sed -i --follow-symlinks "/^account.*required.*pam_unix.so/i account     required      pam_faillock.so" $pamFile
	fi
done
