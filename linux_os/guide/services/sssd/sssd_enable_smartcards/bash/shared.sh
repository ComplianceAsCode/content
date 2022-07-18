# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_ensure_ini_config("/etc/sssd/sssd.conf", "pam", "pam_cert_auth", "True") }}}

{{% if product in ["fedora", "ol8", "rhel8", "rhel9"] %}}
if [ -f /usr/bin/authselect ]; then
    if authselect check; then
        {{{ bash_enable_authselect_feature('with-smartcard') | indent(8) }}}
    fi
else
    {{{ bash_ensure_pam_module_option('/etc/pam.d/smartcard-auth', 'auth', 'sufficient', 'pam_sss.so', 'allow_missing_name', '', '') | indent(4) }}}
    {{{ bash_ensure_pam_module_option('/etc/pam.d/system-auth', 'auth', '\[success=done authinfo_unavail=ignore ignore=ignore default=die\]', 'pam_sss.so', 'try_cert_auth', '', '') | indent(4) }}}
fi
{{% endif %}}
