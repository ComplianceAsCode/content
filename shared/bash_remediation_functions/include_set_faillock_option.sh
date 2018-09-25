function include_set_faillock_option {
	:
}

function insert_preauth {
	local pam_file="$1"
	local option="$2"
	local value="$3"
	# is auth required pam_faillock.so preauth present?
	if grep -qE "^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*$" "$pam_file" ; then
		# is the option set?
		if grep -qE "^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*$option=([0-9]*).*$" "$pam_file" ; then
			# just change the value of option to a correct value
			sed -i --follow-symlinks "s/\(^auth.*required.*pam_faillock.so.*preauth.*silent.*\)\($option *= *\).*/\1\2$value/" "$pam_file"
		# the option is not set.
		else
			# append the option
			sed -i --follow-symlinks "/^auth.*required.*pam_faillock.so.*preauth.*silent.*/ s/$/ $option=$value/" "$pam_file"
		fi
	# auth required pam_faillock.so preauth is not present, insert the whole line
	else
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent $option=$value" "$pam_file"
	fi
}

function insert_authfail {
	local pam_file="$1"
	local option="$2"
	local value="$3"
	# is auth default pam_faillock.so authfail present?
	if grep -qE "^\s*auth\s+(\[default=die\])\s+pam_faillock\.so\s+authfail.*$" "$pam_file" ; then
		# is the option set?
		if grep -qE "^\s*auth\s+(\[default=die\])\s+pam_faillock\.so\s+authfail.*$option=([0-9]*).*$" "$pam_file" ; then
			# just change the value of option to a correct value
			sed -i --follow-symlinks "s/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\($option *= *\).*/\1\2$value/" "$pam_file"
		# the option is not set.
		else
			# append the option
			sed -i --follow-symlinks "/^auth.*[default=die].*pam_faillock.so.*authfail.*/ s/$/ $option=$value/" "$pam_file"
		fi
	# auth default pam_faillock.so authfail is not present, insert the whole line
	else
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail $option=$value" "$pam_file"
	fi
}

function insert_account {
	local pam_file="$1"
	if ! grep -qE "^\s*account\s+required\s+pam_faillock\.so.*$" "$pam_file" ; then
		sed -E -i --follow-symlinks "/^\s*account\s*required\s*pam_unix.so/i account     required      pam_faillock.so" "$pam_file"
	fi
}

function set_faillock_option {
	local pam_file="$1"
	local option="$2"
	local value="$3"
	insert_preauth "$pam_file" "$option" "$value"
	insert_authfail "$pam_file" "$option" "$value"
	insert_account "$pam_file"
}
