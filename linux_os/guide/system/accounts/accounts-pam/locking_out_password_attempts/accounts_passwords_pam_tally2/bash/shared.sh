# platform = multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_password_pam_tally2") }}}
# Use a non-number regexp to force update of the value of the deny option
{{{ bash_ensure_pam_module_option('/etc/pam.d/common-auth', 'auth', 'required', 'pam_tally2.so', 'deny', "${var_password_pam_tally2}", '') }}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/common-auth', 'auth', 'required', 'pam_tally2.so', 'onerr', 'fail', '(fail)') }}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/common-account', 'account', 'required', 'pam_tally2.so', '', '', '') }}}
