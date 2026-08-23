#!/bin/bash
# variables = var_password_pam_delay=4000000

{{%- if 'ubuntu' in product %}}
cat << EOF > /usr/share/pam-configs/tmp_faildelay
Name: Enable faildelay
Conflicts: faildelay
Default: yes
Priority: 512
Auth-Type: Primary
Auth:
    required                   #pam_faildelay.so delay=4000000
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update --enable tmp_faildelay
rm -f /usr/share/pam-configs/tmp_faildelay
{{%- else %}}
echo '# auth required pam_faildelay.so delay=4000000'  > /etc/pam.d/common-auth
{{%- endif %}}
