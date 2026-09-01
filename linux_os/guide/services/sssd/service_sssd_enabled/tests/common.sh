# sssd.service needs /etc/sssd/sssd.conf to start
SSSD_CONF="/etc/sssd/sssd.conf"
SSSD_CONF_DIR="/etc/sssd/conf.d"
{{{ bash_sssd_ensure_default_config("$SSSD_CONF", "$SSSD_CONF_DIR") }}}

{{%- if ('rhel' in product or 'ol' in families) and product not in ['ol7', 'ol8', 'ol9', 'rhel8', 'rhel9']%}}
{{{ bash_ensure_ini_config("$SSSD_CONF $SSSD_CONF_DIR/*.conf", "pam", "pam_cert_auth", "True") }}}
{{%- endif %}}

{{%- if product in ["fedora"] or (('rhel' in product or 'ol' in families) and product not in ['ol7', 'ol8', 'ol9', 'rhel8', 'rhel9']) %}}
{{{ bash_package_install("sssd-proxy") }}}
authselect select sssd with-smartcard
chmod 0640 $SSSD_CONF
{{%- else %}}
chmod 0600 $SSSD_CONF
{{%- endif %}}
