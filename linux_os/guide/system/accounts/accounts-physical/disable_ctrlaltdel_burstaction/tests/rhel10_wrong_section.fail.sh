#!/bin/bash
# platform = Red Hat Enterprise Linux 10

mkdir -p /etc/systemd/system.conf.d
cat << EOF > /etc/systemd/system.conf.d/55-CtrlAltDel-BurstAction.conf
[Sleep]
CtrlAltDelBurstAction=none
[Manager]
LogLevel=info
EOF
