#!/bin/bash

{{% if product in ["rhel8", "rhel9", "rhel10"] %}}
mkdir -p /etc/systemd/system.conf.d
cat << EOF > /etc/systemd/system.conf.d/55-CtrlAltDel-BurstAction.conf
[Manager]
CtrlAltDelBurstAction=poweroff-immediate
EOF
{{% else %}}
# make sure the file exist
touch /etc/systemd/system.conf

if grep -q "^CtrlAltDelBurstAction=" /etc/systemd/system.conf; then
	sed -i "s/^CtrlAltDelBurstAction.*/CtrlAltDelBurstAction=poweroff-immediate/" /etc/systemd/system.conf
else
	echo "CtrlAltDelBurstAction=poweroff-immediate" >> /etc/systemd/system.conf
fi
{{% endif %}}
