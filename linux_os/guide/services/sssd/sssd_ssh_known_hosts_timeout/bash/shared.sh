# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

{{{ bash_instantiate_variables("var_sssd_ssh_known_hosts_timeout") }}}

# sssd configuration files must be created with 600 permissions if they don't exist
# otherwise the sssd module fails to start
OLD_UMASK=$(umask)
umask u=rw,go=

SSSD_CONF="/etc/sssd/sssd.conf"
SSSD_CONF_DIR="/etc/sssd/conf.d"
{{{ bash_sssd_ensure_default_config("$SSSD_CONF", "$SSSD_CONF_DIR") }}}
{{{ bash_install_sssd_proxy() }}}

{{{ bash_ensure_ini_config("$SSSD_CONF", "ssh", "ssh_known_hosts_timeout", "$var_sssd_ssh_known_hosts_timeout") }}}

umask $OLD_UMASK
