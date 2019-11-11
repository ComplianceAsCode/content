# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

# include our remediation functions library
. /usr/share/scap-security-guide/remediation_functions

populate var_accounts_passwords_pam_faillock_fail_interval

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pam_file in "${AUTH_FILES[@]}"
do
	{{{ bash_set_faillock_option("$pam_file", "fail_interval", "$var_accounts_passwords_pam_faillock_fail_interval") }}}
done
