#!/bin/bash
# packages = sssd
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8

source common.sh

{{{ bash_package_install("authselect") }}}

authselect create-profile testingProfile --base-on minimal
authselect select --force custom/testingProfile

echo "[pam]" > $SSSD_FILE
echo "pam_cert_auth = True" >> $SSSD_FILE
