# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_fail_interval") }}}

{{{ bash_set_faillock_option("fail_interval", "$var_accounts_passwords_pam_faillock_fail_interval") }}}
