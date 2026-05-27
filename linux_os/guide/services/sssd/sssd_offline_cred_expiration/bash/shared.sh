# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

# sssd configuration files must be created with 600 permissions if they don't exist
# otherwise the sssd module fails to start
OLD_UMASK=$(umask)
umask u=rw,go=

SSSD_CONF="/etc/sssd/sssd.conf"
SSSD_CONF_DIR="/etc/sssd/conf.d"
{{{ bash_sssd_ensure_default_config("$SSSD_CONF", "$SSSD_CONF_DIR") }}}
{{{ bash_install_sssd_proxy() }}}

{{{ bash_ensure_ini_config("$SSSD_CONF $SSSD_CONF_DIR/*.conf", "pam", "offline_credentials_expiration", "1") }}}

umask $OLD_UMASK
