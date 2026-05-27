# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_almalinux

# sssd configuration files must be created with 600 permissions if they don't exist
# otherwise the sssd module fails to start
OLD_UMASK=$(umask)
umask u=rw,go=

SSSD_CONF="/etc/sssd/sssd.conf"
SSSD_CONF_DIR="/etc/sssd/conf.d"
{{{ bash_sssd_ensure_default_config("$SSSD_CONF", "$SSSD_CONF_DIR") }}}
{{{ bash_install_sssd_proxy() }}}

MAIN_CONF="$SSSD_CONF_DIR/ospp.conf"

{{{ bash_ensure_ini_config("$MAIN_CONF $SSSD_CONF $SSSD_CONF_DIR/*.conf", "sssd", "user", "sssd", remove_wrong_entries=true) }}}

umask $OLD_UMASK
