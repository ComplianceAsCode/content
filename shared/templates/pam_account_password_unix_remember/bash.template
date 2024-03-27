# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

{{% if "debian" in product or "ubuntu" in product or product in ["sle12", "sle15" ] %}}
{{%- set accounts_password_pam_unix_remember_file = '/etc/pam.d/common-password' -%}}
{{% else %}}
{{%- set accounts_password_pam_unix_remember_file = '/etc/pam.d/system-auth' -%}}
{{% endif %}}

{{% if "debian" in product or "ubuntu" in product %}}

{{{ bash_ensure_pam_module_options(accounts_password_pam_unix_remember_file, 'password', '\[success=[[:alnum:]].*\]', 'pam_unix.so', 'remember', "$var_password_pam_unix_remember", "$var_password_pam_unix_remember") }}}

{{% else %}}

{{{ bash_pam_pwhistory_enable(accounts_password_pam_unix_remember_file,
                              'requisite',
                              '^password.*requisite.*pam_pwquality\.so') }}}

{{{ bash_pam_pwhistory_parameter_value(accounts_password_pam_unix_remember_file,
                                       'remember',
                                       "$var_password_pam_unix_remember") }}}

{{% endif %}}

