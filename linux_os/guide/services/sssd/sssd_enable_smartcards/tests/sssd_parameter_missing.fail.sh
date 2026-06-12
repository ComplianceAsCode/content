#!/bin/bash
# packages = sssd
# platform = multi_platform_fedora,Oracle Linux 7,Red Hat Virtualization 4,multi_platform_ubuntu

{{% if product in ["fedora", "ol8", "ol9"] or 'rhel' in product %}}
authselect select sssd --force
{{% endif %}}

SSSD_FILE="/etc/sssd/sssd.conf"
echo "[pam]" > $SSSD_FILE
