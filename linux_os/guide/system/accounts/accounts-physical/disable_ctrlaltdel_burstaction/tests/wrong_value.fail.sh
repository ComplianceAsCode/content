#!/bin/bash

{{% if product == "rhel8" or product == "rhel9" %}}
mkdir -p /etc/systemd/system.conf.d
cat << EOF > /etc/systemd/system.conf.d/55-CtrlAltDel-BurstAction.conf
[Manager]
CtrlAltDelBurstAction=poweroff-immediate
EOF
{{% else %}}
touch /etc/systemd/system.conf

if grep -q "^CtrlAltDelBurstAction=" /etc/systemd/system.conf; then
	sed -i "s/^CtrlAltDelBurstAction.*/CtrlAltDelBurstAction=poweroff-immediate/" /etc/systemd/system.conf
else
	echo "CtrlAltDelBurstAction=poweroff-immediate" >> /etc/systemd/system.conf
fi
{{% endif %}}
