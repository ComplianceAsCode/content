#!/bin/bash
# variables = var_password_pam_delay=4000000

{{%- if product == "ubuntu2404" %}}
{{%- else %}}
if grep -q 'pam_faildelay.so' /etc/pam.d/common-auth; then
    sed -i --follow-symlinks "/pam_faildelay\.so/d" /etc/pam.d/common-auth
fi
{{%- endif %}}
