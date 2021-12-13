#!/bin/bash
{{%- if product in ["rhel7"] %}}
# packages = authconfig
{{%- else %}}
# packages = authselect
{{%- endif %}}

if [ -f /usr/sbin/authconfig ]; then
    authconfig --disablefaillock --update
else
    authselect select sssd --force
    authselect disable-feature with-faillock
fi
