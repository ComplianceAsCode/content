# platform = multi_platform_sle,multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_ensure_pam_module_option('/etc/pam.d/common-auth', 'auth', 'required', 'pam_tally2.so', 'even_deny_root', '', '') }}}

{{{ bash_ensure_pam_module_option('/etc/pam.d/common-account', 'account', 'required', 'pam_tally2.so', '', '', '') }}}
