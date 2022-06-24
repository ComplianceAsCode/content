#!/bin/bash
# packages = sssd
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8

source common.sh

{{{ bash_package_install("authselect") }}}

{{% if product in ["ol8"] %}}
authselect create-profile testingProfile --base-on minimal
{{% else %}}
# The minimal profile doesn't have with-smartcard feature
authselect create-profile testingProfile --base-on sssd
{{% endif %}}
authselect select --force custom/testingProfile

echo "[pam]" > $SSSD_FILE
echo "pam_cert_auth = True" >> $SSSD_FILE
