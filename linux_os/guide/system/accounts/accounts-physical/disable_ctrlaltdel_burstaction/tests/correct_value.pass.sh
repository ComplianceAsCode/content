#!/bin/bash

{{% if "rhel" in families %}}
mkdir -p /etc/systemd/system.conf.d
cat << EOF > /etc/systemd/system.conf.d/55-CtrlAltDel-BurstAction.conf
[Manager]
CtrlAltDelBurstAction=none
EOF
{{% else %}}
touch /etc/systemd/system.conf

if grep -q "^CtrlAltDelBurstAction=" /etc/systemd/system.conf; then
	sed -i "s/^CtrlAltDelBurstAction.*/CtrlAltDelBurstAction=none/" /etc/systemd/system.conf
else
	echo "CtrlAltDelBurstAction=none" >> /etc/systemd/system.conf
fi
{{% endif %}}
