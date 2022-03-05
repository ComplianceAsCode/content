# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

MAIN_CONF="/etc/sssd/conf.d/ospp.conf"

{{{ bash_ensure_ini_config("$MAIN_CONF /etc/sssd/sssd.conf /etc/sssd/conf.d/*.conf", "sssd", "user", "sssd") }}}

if [ -e "$MAIN_CONF" ]; then
    chown root:root "$MAIN_CONF"
	chmod 600 "$MAIN_CONF"
fi
