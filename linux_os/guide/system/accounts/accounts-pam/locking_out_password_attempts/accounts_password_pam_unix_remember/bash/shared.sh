# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

{{% if product in [ "sle12", "sle15" ] %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/common-password', 'password', 'requisite', 'pam_pwhistory.so', 'remember', "$var_password_pam_unix_remember", '') }}}
{{% else %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/system-auth', 'password', 'requisite', 'pam_pwhistory.so', 'remember', "$var_password_pam_unix_remember", '^password.*requisite.*pam_pwquality\.so') }}}
{{% endif %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/password-auth', 'password', 'requisite', 'pam_pwhistory.so', 'remember', "$var_password_pam_unix_remember", '^password.*requisite.*pam_pwquality\.so') }}}
