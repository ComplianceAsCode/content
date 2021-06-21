# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

{{% macro bash_pam_remember(module, control) %}}
for pamFile in "${AUTH_FILES[@]}"
do
	if grep -q "remember=" $pamFile; then
		sed -i --follow-symlinks "s/\(^password.*{{{ control }}}.*{{{ module }}}.so.*\)\(\(remember *= *\)[^ $]*\)/\1remember=$var_password_pam_unix_remember/" $pamFile
	else
		sed -i --follow-symlinks "/^password[[:space:]]\+{{{ control }}}[[:space:]]\+{{{ module }}}.so/ s/$/ remember=$var_password_pam_unix_remember/" $pamFile
	fi
done
{{%- endmacro -%}}

{{{ bash_pam_remember(module="pam_unix", control="sufficient") }}}
