# platform = multi_platform_all

{{% if product in ['ol8', 'ol9', 'rhel8', 'rhel9'] %}}
{{% set configuration_files = ["password-auth","system-auth"] %}}
{{% else %}}
{{% set configuration_files = ["system-auth"] %}}
{{% endif %}}


{{{ bash_instantiate_variables("var_password_pam_retry") }}}

{{% if product in ['ol8', 'ol9', 'rhel8', 'rhel9'] -%}}
	{{{ bash_replace_or_append('/etc/security/pwquality.conf',
							   '^retry',
							   '$var_password_pam_retry',
							   '%s = %s') }}}
	{{% for cfile in configuration_files %}}
		{{{ bash_remove_pam_module_option_configuration(pam_file='/etc/pam.d/' ~ cfile,
									  	  				group='password',
														control=".*",
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
