#!/bin/bash
# packages = sssd
# platform = multi_platform_fedora,Oracle Linux 7,Red Hat Virtualization 4,multi_platform_ubuntu

SSSD_FILE="/etc/sssd/sssd.conf"
{{{ bash_ensure_ini_config("$SSSD_FILE", "pam", "pam_cert_auth", "True") }}}

{{% if product in ["fedora", "ol8", "ol9"] or 'rhel' in product %}}
authselect select sssd --force
authselect enable-feature with-smartcard
authselect apply-changes
{{% endif %}}
