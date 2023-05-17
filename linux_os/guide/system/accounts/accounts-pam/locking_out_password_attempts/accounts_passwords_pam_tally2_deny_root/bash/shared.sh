# platform = multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_remove_pam_module_option('/etc/pam.d/login', 'auth', 'required', 'pam_tally2.so', 'onerr=fail') }}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/login', 'auth', 'required', 'pam_tally2.so', 'even_deny_root', '', '') }}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/common-account', 'account', 'required', 'pam_tally2.so', '', '', '') }}}
