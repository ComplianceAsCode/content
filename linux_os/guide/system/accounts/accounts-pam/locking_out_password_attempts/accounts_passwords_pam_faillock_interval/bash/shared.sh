# platform = multi_platform_rhel, multi_platform_fedora

# include our remediation functions library
. /usr/share/scap-security-guide/remediation_functions

populate var_accounts_passwords_pam_faillock_fail_interval

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

function insert_preauth {
	local pam_file="$1"
	local fail_interval="$2"
	# is auth required pam_faillock.so preauth present?
	if grep -qE "^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*$" "$pam_file" ; then
		# is the fail_interval option set?
		if grep -qE "^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*fail_interval=([0-9]*).*$" "$pam_file" ; then
			# just change the value of fail_interval option to a correct value
			sed -i --follow-symlinks "s/\(^auth.*required.*pam_faillock.so.*preauth.*silent.*\)\(fail_interval *= *\).*/\1\2$fail_interval/" "$pam_file"
		# fail_interval option is not set.
		else
			# append a fail_interval option
			sed -i --follow-symlinks "/^auth.*required.*pam_faillock.so.*preauth.*silent.*/ s/$/ fail_interval=$fail_interval/" "$_pamFile"
		fi
	# auth required pam_faillock.so preauth is not present, insert the whole line
	else
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent fail_interval=$fail_interval" "$pam_file"
	fi
}

function insert_authfail {
	local pam_file="$1"
	local fail_interval="$2"
	# is auth default pam_faillock.so authfail present?
	if grep -qE "^\s*auth\s+(\[default=die\])\s+pam_faillock\.so\s+authfail.*$" "$pam_file" ; then
		# is the fail_interval option set?
		if grep -qE "^\s*auth\s+(\[default=die\])\s+pam_faillock\.so\s+authfail.*fail_interval=([0-9]*).*$" "$pam_file" ; then
			# just change the value of fail_interval option to a correct value
			sed -i --follow-symlinks "s/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\(fail_interval *= *\).*/\1\2$fail_interval/" "$pam_file"
		# fail_interval option is not set.
		else
			# append a fail_interval option
			sed -i --follow-symlinks "/^auth.*[default=die].*pam_faillock.so.*authfail.*/ s/$/ fail_interval=$fail_interval/" "$_pamFile"
		fi
	# auth default pam_faillock.so authfail is not present, insert the whole line
	else
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail fail_interval=$fail_interval" "$pam_file"
	fi
}

function insert_account {
	local pam_file="$1"
	if ! grep -qE "^\s*account\s+required\s+pam_faillock\.so.*$" "$pam_file" ; then
		sed -E -i --follow-symlinks "/^\s*account\s*required\s*pam_unix.so/i account     required      pam_faillock.so" "$pam_file"
	fi
}

function set_faillock_in_pam_file {
	local pam_file="$1"
	local fail_interval="$2"
	insert_preauth "$pam_file" "$fail_interval"
	insert_authfail "$pam_file" "$fail_interval"
	insert_account "$pam_file"
}

for pam_file in "${AUTH_FILES[@]}"
do
	set_faillock_in_pam_file "$pam_file" "$var_accounts_passwords_pam_faillock_fail_interval"
done
