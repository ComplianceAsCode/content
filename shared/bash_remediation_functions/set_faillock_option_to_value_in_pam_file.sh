function set_faillock_option_to_value_in_pam_file {
	# If invoked with no arguments, exit. This is an intentional behavior.
	[ $# -gt 1 ] || return 0
	[ $# -ge 3 ] || die "$0 requires exactly zero, three, or four arguments"
	[ $# -le 4 ] || die "$0 requires exactly zero, three, or four arguments"
	local _pamFile="$1" _option="$2" _value="$3" _insert_lines_callback="$4"
	# pam_faillock.so already present?
	if grep -q "^auth.*pam_faillock.so.*" "$_pamFile"; then

		# pam_faillock.so present, is the option present?
		if grep -q "^auth.*[default=die].*pam_faillock.so.*authfail.*$_option=" "$_pamFile"; then

			# both pam_faillock.so & option present, just correct option to the right value
			sed -i --follow-symlinks "s/\(^auth.*required.*pam_faillock.so.*preauth.*silent.*\)\($_option *= *\).*/\1\2$_value/" "$_pamFile"
			sed -i --follow-symlinks "s/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\($_option *= *\).*/\1\2$_value/" "$_pamFile"

		# pam_faillock.so present, but the option not yet
		else

			# append correct option value to appropriate places
			sed -i --follow-symlinks "/^auth.*required.*pam_faillock.so.*preauth.*silent.*/ s/$/ $_option=$_value/" "$_pamFile"
			sed -i --follow-symlinks "/^auth.*[default=die].*pam_faillock.so.*authfail.*/ s/$/ $_option=$_value/" "$_pamFile"
		fi

	# pam_faillock.so not present yet
	else
		test -z "$_insert_lines_callback" || "$_insert_lines_callback" "$_option" "$_value" "$_pamFile"
		# insert pam_faillock.so preauth & authfail rows with proper value of the option in question
	fi
}
