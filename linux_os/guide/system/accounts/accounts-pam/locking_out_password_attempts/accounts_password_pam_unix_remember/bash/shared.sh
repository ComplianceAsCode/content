# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
	if grep -q ".*pwhistory\.so.*remember=" $pamFile; then
		sed -i -E --follow-symlinks "s/(^password.*pam_pwhistory\.so.*)(remember\s*=\s*[0-9]+)(.*$)/\1remember=$var_password_pam_unix_remember \3/" $pamFile
	elif grep -q ".*pwhistory\.so.*" $pamFile; then
		sed -i --follow-symlinks "/^password[[:space:]]\+.*[[:space:]]\+pam_pwhistory\.so/ s/$/ remember=$var_password_pam_unix_remember/" $pamFile
	elif grep -q ".*unix\.so.*remember=" $pamFile; then
		sed -i -E --follow-symlinks "s/(^password.*pam_unix\.so.*)(remember\s*=\s*[0-9]+)(.*$)/\1remember=$var_password_pam_unix_remember \3/" $pamFile
	elif grep -q ".*unix\.so.*" $pamFile; then
		sed -i --follow-symlinks "/^password[[:space:]]\+.*[[:space:]]\+pam_unix\.so/ s/$/ remember=$var_password_pam_unix_remember/" $pamFile
	else
		sed -i -E --follow-symlinks '0,/^password/s/(^password.*)/\1\npassword requisite pam_pwhistory.so remember=$var_password_pam_unix_remember/' $pamFile
	fi
done
