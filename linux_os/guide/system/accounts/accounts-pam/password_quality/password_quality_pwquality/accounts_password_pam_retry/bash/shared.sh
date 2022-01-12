# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_pam_retry") }}}

{{% if product in ['rhel8', 'rhel9'] -%}}
	{{{ bash_replace_or_append('/etc/security/pwquality.conf', '^retry', '$var_password_pam_retry', '%s = %s') }}}
{{% else %}}
	if grep -q "retry=" /etc/pam.d/system-auth ; then
		sed -i --follow-symlinks "s/\(retry *= *\).*/\1$var_password_pam_retry/" /etc/pam.d/system-auth
	else
		sed -i --follow-symlinks "/pam_pwquality.so/ s/$/ retry=$var_password_pam_retry/" /etc/pam.d/system-auth
	fi
{{%- endif %}}
