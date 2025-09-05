# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_pam_retry") }}}

{{% if product in ['rhel8', 'rhel9'] -%}}
	{{{ bash_replace_or_append('/etc/security/pwquality.conf', '^retry', '$var_password_pam_retry', '%s = %s') }}}
{{% else %}}
	{{{ bash_ensure_pam_module_option('/etc/pam.d/system-auth', 'password', 'requisite', 'pam_pwquality.so', 'retry', "$var_password_pam_retry", '^account.*required.*pam_permit.so') }}}
{{%- endif %}}
