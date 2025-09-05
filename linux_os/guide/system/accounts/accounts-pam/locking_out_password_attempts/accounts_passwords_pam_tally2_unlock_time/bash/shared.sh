# platform = multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_accounts_passwords_pam_tally2_unlock_time") }}}
# Use a non-number regexp to force update of the value of the deny option
{{{ bash_ensure_pam_module_option('/etc/pam.d/login', 'auth', 'required', 'pam_tally2.so', 'unlock_time', "${var_accounts_passwords_pam_tally2_unlock_time}", '') }}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/common-account', 'account', 'required', 'pam_tally2.so', '', '', '') }}}
