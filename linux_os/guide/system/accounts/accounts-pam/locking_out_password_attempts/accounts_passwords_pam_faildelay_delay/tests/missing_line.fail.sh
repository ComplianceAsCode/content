#!/bin/bash
# variables = var_password_pam_delay=4000000

{{%- if 'ubuntu' in product %}}
{{%- else %}}
if [ ! -f "/etc/pam.d/common-auth" ] ; then
    touch /etc/pam.d/common-auth
fi

if grep -q 'pam_faildelay.so' /etc/pam.d/common-auth; then
    sed -i --follow-symlinks "/pam_faildelay\.so/d" /etc/pam.d/common-auth
fi
{{%- endif %}}
