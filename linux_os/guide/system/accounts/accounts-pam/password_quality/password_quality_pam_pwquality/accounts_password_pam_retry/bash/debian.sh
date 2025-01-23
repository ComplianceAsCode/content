# platform = multi_platform_debian

{{{ bash_instantiate_variables("var_password_pam_retry") }}}

{{{ bash_ensure_pam_module_options('/etc/pam.d/common-password', 'password', 'requisite', 'pam_pwquality.so', 'retry', "$var_password_pam_retry", "$var_password_pam_retry") }}}
