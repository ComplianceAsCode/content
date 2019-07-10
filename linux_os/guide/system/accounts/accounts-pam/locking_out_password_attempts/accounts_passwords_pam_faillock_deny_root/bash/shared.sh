# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

# This script fixes absence of pam_faillock.so in PAM stack or the
# absense of even_deny_root in pam_faillock.so arguments
# When inserting auth pam_faillock.so entries,
# the entry with preauth argument will be added before pam_unix.so module
# and entry with authfail argument will be added before pam_deny.so module.

# The placement of pam_faillock.so entries will not be changed
# if they are already present

for pamFile in "${AUTH_FILES[@]}"
do
	# if PAM file is missing, system is not using PAM or broken
	if [ ! -f $pamFile ]; then
		continue
	fi

	# is 'auth required' here?
	if grep -q "^auth.*required.*pam_faillock.so.*" $pamFile; then
		# has 'auth required' even_deny_root option?
		if ! grep -q "^auth.*required.*pam_faillock.so.*preauth.*even_deny_root" $pamFile; then
			# even_deny_root is not present
			sed -i --follow-symlinks "s/\(^auth.*required.*pam_faillock.so.*preauth.*\).*/\1 even_deny_root/" $pamFile
		fi
	else
		# no 'auth required', add it
		sed -i --follow-symlinks "/^auth.*pam_unix.so.*/i auth required pam_faillock.so preauth silent even_deny_root" $pamFile
	fi

	# is 'auth [default=die]' here?
	if grep -q "^auth.*\[default=die\].*pam_faillock.so.*" $pamFile; then
		# has 'auth [default=die]' even_deny_root option?
		if ! grep -q "^auth.*\[default=die\].*pam_faillock.so.*authfail.*even_deny_root" $pamFile; then
			# even_deny_root is not present
			sed -i --follow-symlinks "s/\(^auth.*\[default=die\].*pam_faillock.so.*authfail.*\).*/\1 even_deny_root/" $pamFile
		fi
	else
		# no 'auth [default=die]', add it
		sed -i --follow-symlinks "/^auth.*pam_unix.so.*/a auth [default=die] pam_faillock.so authfail silent even_deny_root" $pamFile
	fi
done
