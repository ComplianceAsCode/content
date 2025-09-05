# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_password_pam_unix_rounds") }}}

{{{ bash_ensure_pam_module_configuration('/etc/pam.d/system-auth', 'password', 'sufficient', 'pam_unix.so', 'rounds', "$var_password_pam_unix_rounds", '') }}}
