# platform = multi_platform_sle

{{{ bash_ensure_pam_module_options('/etc/pam.d/common-auth', 'auth', 'required', 'pam_tally2.so', 'deny', '[123]', '3') }}}
{{{ bash_ensure_pam_module_options('/etc/pam.d/common-auth', 'auth', 'required', 'pam_tally2.so', 'onerr', '(fail)', 'fail') }}}
{{{ bash_ensure_pam_module_options('/etc/pam.d/common-account', 'account', 'required', 'pam_tally2.so', '', '', '') }}}
