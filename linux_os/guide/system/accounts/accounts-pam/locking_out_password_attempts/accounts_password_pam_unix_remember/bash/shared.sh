# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{% if product in [ "sle12", "sle15" ] %}}
{{%- set accounts_password_pam_unix_remember_file = '/etc/pam.d/common-password' -%}}
{{% else %}}
{{%- set accounts_password_pam_unix_remember_file = '/etc/pam.d/system-auth' -%}}
{{% endif %}}

{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

{{{ bash_pam_pwhistory_enable(accounts_password_pam_unix_remember_file,
                              'requisite',
                              '^password.*requisite.*pam_pwquality\.so') }}}

{{{ bash_pam_pwhistory_parameter_value(accounts_password_pam_unix_remember_file,
                                       'remember',
                                       "$var_password_pam_unix_remember") }}}
