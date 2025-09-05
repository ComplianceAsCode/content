# platform = multi_platform_ubuntu

{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

{{{ bash_ensure_pam_module_options('/etc/pam.d/common-password', 'password', '[success=1 default=ignore]', 'pam_unix.so', 'obscure sha512 shadow remember', "$var_password_pam_unix_remember", "$var_password_pam_unix_remember") }}}
