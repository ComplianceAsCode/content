# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_passwords_remember

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
	if grep -q "pam_pwhistory.so" $pamFile; then
		if grep -q "remember=" $pamFile; then
			sed -i --follow-symlinks "s/\(^password.*requisite.*pam_pwhistory.so.*\)remember *= *[0-9]*[ ]*\(.*\)/\1remember=${var_accounts_passwords_remember} \2/" $pamFile
		else
			sed -i --follow-symlinks "/^password[[:space:]]\+requisite[[:space:]]\+pam_pwhistory.so/ s/$/ remember=${var_accounts_passwords_remember}/" $pamFile
		fi
	else
		if grep -q "pam_cracklib.so" $pamFile; then
			sed -i --follow-symlinks "/password.*pam_cracklib.so/apassword    requisite     pam_pwhistory.so use_authtok remember=${var_accounts_passwords_remember} retry=3" $pamFile
		elif grep -q "pam_pwquality.so" $pamFile; then
			sed -i --follow-symlinks "/password.*pam_pwquality.so/apassword    requisite     pam_pwhistory.so use_authtok remember=${var_accounts_passwords_remember} retry=3" $pamFile
		fi
	fi
done
