#!/bin/bash
# packages = authselect,sssd
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,multi_platform_rhel

SSSD_FILE="/etc/sssd/sssd.conf"
echo "[pam]" > $SSSD_FILE
echo "pam_cert_auth = True" >> $SSSD_FILE

authselect select sssd --force
authselect disable-feature with-smartcard
authselect apply-changes
