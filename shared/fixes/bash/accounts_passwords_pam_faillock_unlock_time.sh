# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_passwords_pam_faillock_unlock_time

# Invoke the function without args, so its body is substituded right here.
set_faillock_option_to_value_in_pam_file

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"


function insert_lines_if_pam_faillock_so_not_present {
	local _option="$1" _value="$2" _pamFile="$3"
	sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent $_option=$_value" "$_pamFile"
	sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail $_option=$_value" "$_pamFile"
	sed -i --follow-symlinks "/^account.*required.*pam_unix.so/i account     required      pam_faillock.so" "$_pamFile"
}


for pamFile in "${AUTH_FILES[@]}"
do
	# 'true &&' has to be there due to build system limitation
	true && set_faillock_option_to_value_in_pam_file "$pamFile" unlock_time "$var_accounts_passwords_pam_faillock_unlock_time" insert_lines_if_pam_faillock_so_not_present
done
