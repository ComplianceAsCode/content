# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_almalinux

MAIN_CONF="/etc/sssd/conf.d/ospp.conf"

# sssd configuration files must be created with 600 permissions if they don't exist
# otherwise the sssd module fails to start
OLD_UMASK=$(umask)
umask u=rw,go=

{{{ bash_ensure_ini_config("$MAIN_CONF /etc/sssd/sssd.conf /etc/sssd/conf.d/*.conf", "sssd", "user", "sssd") }}}

umask $OLD_UMASK
