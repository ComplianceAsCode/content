#!/bin/bash
# packages = sssd
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8

source common.sh

echo "[pam]" > $SSSD_FILE
echo "pam_cert_auth = True" >> $SSSD_FILE
