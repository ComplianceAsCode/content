# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_fail_interval") }}}

{{{ bash_pam_faillock_enable() }}}
{{{ bash_pam_faillock_parameter_value("fail_interval", "$var_accounts_passwords_pam_faillock_fail_interval") }}}
