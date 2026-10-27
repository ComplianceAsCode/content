#!/bin/bash

{{% if "rhel" in families %}}
mkdir -p /etc/systemd/system.conf.d
cat << EOF > /etc/systemd/system.conf.d/55-CtrlAltDel-BurstAction.conf
[Manager]
EOF
{{% else %}}
touch /etc/systemd/system.conf

sed -i "/^CtrlAltDelBurstAction.*/d" /etc/systemd/system.conf
{{% endif %}}
