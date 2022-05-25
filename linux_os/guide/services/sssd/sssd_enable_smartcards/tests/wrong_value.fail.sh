#!/bin/bash
# packages = sssd

source common.sh

echo "[pam]" > $SSSD_FILE
echo "pam_cert_auth = False" >> $SSSD_FILE

{{% if product in ["ol8", "rhel8"] %}}
{{{ bash_ensure_pam_module_options('/etc/pam.d/smartcard-auth', 'auth', 'sufficient', 'pam_sss.so', 'try_cert_auth', '', '') }}}
{{{ bash_ensure_pam_module_options('/etc/pam.d/system-auth', 'auth', 'sufficient', 'pam_sss.so', 'try_cert_auth', '', '') }}}
{{% endif %}}
