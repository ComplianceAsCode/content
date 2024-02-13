# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

# sssd configuration files must be created with 600 permissions if they don't exist
# otherwise the sssd module fails to start
OLD_UMASK=$(umask)
umask u=rw,go=

{{{ bash_ensure_ini_config("/etc/sssd/sssd.conf /etc/sssd/conf.d/*.conf", "pam", "offline_credentials_expiration", "1") }}}

umask $OLD_UMASK
