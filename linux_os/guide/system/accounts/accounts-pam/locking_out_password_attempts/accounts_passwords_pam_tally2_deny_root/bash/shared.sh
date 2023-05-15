# platform = multi_platform_sle,multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{% if product in ["sle12","sle15"] %}}
{{{ bash_remove_pam_module_option('/etc/pam.d/login', 'auth', 'required', 'pam_tally2.so', 'onerr=fail') }}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/login', 'auth', 'required', 'pam_tally2.so', 'even_deny_root', '', '') }}}
{{% else %}}
{{{ bash_remove_pam_module_option('/etc/pam.d/common-auth', 'auth', 'required', 'pam_tally2.so', 'onerr=fail') }}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/common-auth', 'auth', 'required', 'pam_tally2.so', 'even_deny_root', '', '') }}}
{{% endif %}}
{{{ bash_ensure_pam_module_option('/etc/pam.d/common-account', 'account', 'required', 'pam_tally2.so', '', '', '') }}}
