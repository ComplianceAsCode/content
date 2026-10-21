#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

mkdir -p /etc/systemd/system.conf.d
rm -f /etc/systemd/system.conf.d/*.conf
cat << EOF > /etc/systemd/system.conf
[Manager]
EOF
cat << EOF > /etc/systemd/system.conf.d/55-CtrlAltDel-BurstAction.conf
[Manager]
[Other]
CtrlAltDelBurstAction=none
EOF
