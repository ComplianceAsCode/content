#!/bin/bash
# packages = sssd
# platform = multi_platform_fedora,Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4

SSSD_FILE="/etc/sssd/sssd.conf"
echo "[pam]" > $SSSD_FILE
