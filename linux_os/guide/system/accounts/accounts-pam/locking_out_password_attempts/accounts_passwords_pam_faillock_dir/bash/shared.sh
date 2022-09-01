# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_dir") }}}

{{{ bash_pam_faillock_enable() }}}
{{{ bash_pam_faillock_parameter_value("dir", "$var_accounts_passwords_pam_faillock_dir") }}}
