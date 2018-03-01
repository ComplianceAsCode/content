function substitute_in_pam_file {
    # If invoked with no arguments, exit. This is an intentional behavior.
    [ $# -gt 1 ] || return 0
    [ $# = 3 ] || die "$0 requires zero or exactly three arguments"
	local _pamfile="$1" _directive="$2" _value="$3"
	# pam_faillock.so already present?
	if grep -q "^auth.*pam_faillock.so.*" "$_pamFile"; then

		# pam_faillock.so present, is the directive present?
		if grep -q "^auth.*[default=die].*pam_faillock.so.*authfail.*$_directive=" "$_pamFile"; then

			# both pam_faillock.so & directive present, just correct directive to the right value
			sed -i --follow-symlinks "s/\(^auth.*required.*pam_faillock.so.*preauth.*silent.*\)\($_directive *= *\).*/\1\2$_value/" "$_pamFile"
			sed -i --follow-symlinks "s/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\($_directive *= *\).*/\1\2$_value/" "$_pamFile"

		# pam_faillock.so present, but the directive not yet
		else

			# append correct directive value to appropriate places
			sed -i --follow-symlinks "/^auth.*required.*pam_faillock.so.*preauth.*silent.*/ s/$/ $_directive=$_value/" "$_pamFile"
			sed -i --follow-symlinks "/^auth.*[default=die].*pam_faillock.so.*authfail.*/ s/$/ $_directive=$_value/" "$_pamFile"
		fi

	# pam_faillock.so not present yet
	else

		# insert pam_faillock.so preauth & authfail rows with proper value of the option in question
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent $_directive=$_value" "$_pamFile"
		sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail $_directive=$_value" "$_pamFile"
		sed -i --follow-symlinks "/^account.*required.*pam_unix.so/i account     required      pam_faillock.so" "$_pamFile"
	fi
}
