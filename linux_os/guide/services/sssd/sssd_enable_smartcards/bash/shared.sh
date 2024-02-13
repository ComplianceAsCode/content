# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

# sssd configuration files must be created with 600 permissions if they don't exist
# otherwise the sssd module fails to start
OLD_UMASK=$(umask)
umask u=rw,go=

{{{ bash_ensure_ini_config("/etc/sssd/sssd.conf /etc/sssd/conf.d/*.conf", "pam", "pam_cert_auth", "True") }}}

umask $OLD_UMASK

{{% if product in ["fedora", "ol8", "ol9", "rhel8", "rhel9"] %}}
if [ -f /usr/bin/authselect ]; then
    {{{ bash_enable_authselect_feature('with-smartcard') | indent(4) }}}
else
    {{{ bash_ensure_pam_module_option('/etc/pam.d/smartcard-auth', 'auth', 'sufficient', 'pam_sss.so', 'allow_missing_name', '', '') | indent(4) }}}
    {{{ bash_ensure_pam_module_option('/etc/pam.d/system-auth', 'auth', '\[success=done authinfo_unavail=ignore ignore=ignore default=die\]', 'pam_sss.so', 'try_cert_auth', '', '') | indent(4) }}}
fi
{{% endif %}}
