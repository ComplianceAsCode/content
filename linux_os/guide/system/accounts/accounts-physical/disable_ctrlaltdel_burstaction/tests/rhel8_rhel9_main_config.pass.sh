#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

rm -f /etc/systemd/system.conf.d/*.conf
cat << EOF > /etc/systemd/system.conf
[Manager]
CtrlAltDelBurstAction=none
EOF
