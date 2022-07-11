# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

{{{ bash_instantiate_variables("var_password_pam_remember", "var_password_pam_remember_control_flag") }}}

{{{ bash_ensure_pam_module_configuration('/etc/pam.d/system-auth', 'password', "$var_password_pam_remember_control_flag", 'pam_pwhistory.so', 'remember', "$var_password_pam_remember", '^password.*requisite.*pam_pwquality.so') }}}
