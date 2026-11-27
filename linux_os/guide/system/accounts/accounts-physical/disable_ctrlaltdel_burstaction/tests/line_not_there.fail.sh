#!/bin/bash

{{% if "rhel" in families %}}
mkdir -p /etc/systemd/system.conf.d
cat << EOF > /etc/systemd/system.conf.d/55-CtrlAltDel-BurstAction.conf
[Manager]
OtherSetting=value
EOF
{{% else %}}
# make sure the file exist
touch /etc/systemd/system.conf


sed -i "/^CtrlAltDelBurstAction.*/d" /etc/systemd/system.conf
{{% endif %}}
