# platform = multi_platform_all

{{% if 'ol' in families or 'rhel' in product %}}
{{% set configuration_files = ["password-auth","system-auth"] %}}
{{% elif product in ['sle15', 'sle16'] %}}
{{% set configuration_files = ["common-password"] %}}
{{% else %}}
{{% set configuration_files = ["system-auth"] %}}
{{% endif %}}


{{{ bash_instantiate_variables("var_password_pam_retry") }}}

{{% if 'rhel' in product or product in ['sle15', 'sle16'] -%}}
	{{{ bash_replace_or_append(pwquality_path,
							   '^retry',
							   '$var_password_pam_retry',
							   '%s = %s', cce_identifiers=cce_identifiers) }}}
	{{% for cfile in configuration_files %}}
		{{{ bash_remove_pam_module_option_configuration(pam_file='/etc/pam.d/' ~ cfile,
									  	  				group='password',
																control="",
									      				module='pam_pwquality.so',
									      				option='retry') }}}
	{{% endfor %}}
{{% else %}}
	{{% for cfile in configuration_files %}}
		{{{ bash_ensure_pam_module_configuration('/etc/pam.d/' ~ cfile,
										  'password',
										  'requisite',
										  'pam_pwquality.so',
										  'retry',
										  "$var_password_pam_retry",
										  '^\s*account') }}}
	{{% endfor %}}
{{%- endif %}}
