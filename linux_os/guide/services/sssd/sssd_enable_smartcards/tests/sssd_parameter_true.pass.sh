#!/bin/bash
# packages = sssd
# platform = multi_platform_fedora,Oracle Linux 7,Red Hat Virtualization 4,multi_platform_ubuntu

SSSD_FILE="/etc/sssd/sssd.conf"
echo "[pam]" > $SSSD_FILE
echo "pam_cert_auth = True" >> $SSSD_FILE
