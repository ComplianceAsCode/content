#!/bin/bash
# packages = sssd
# platform = multi_platform_fedora,Oracle Linux 7,Red Hat Virtualization 4,multi_platform_ubuntu

{{% if product in ["fedora", "ol8", "ol9"] or 'rhel' in product %}}
authselect select sssd --force
{{% endif %}}

SSSD_CONF="/etc/sssd/sssd.conf"
SSSD_CONF_DIR="/etc/sssd/conf.d"
{{{ bash_ensure_ini_config("$SSSD_CONF $SSSD_CONF_DIR/*.conf", "pam", "pam_cert_auth", "False") }}}
