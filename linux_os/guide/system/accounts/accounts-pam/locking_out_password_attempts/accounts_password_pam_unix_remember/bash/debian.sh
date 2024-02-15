# platform = multi_platform_debian

{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

{{{ bash_ensure_pam_module_options('/etc/pam.d/common-password', 'password', '\[success=[[:alnum:]].*\]', 'pam_unix.so', 'remember', "$var_password_pam_unix_remember", "$var_password_pam_unix_remember") }}}
