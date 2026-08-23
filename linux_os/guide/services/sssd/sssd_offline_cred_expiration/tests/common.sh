#!/bin/bash
# packages = sssd

SSSD_CONF="/etc/sssd/sssd.conf"

{{% if 'ubuntu' not in product %}}
yum -y install /usr/lib/systemd/system/sssd.service
{{% endif %}}
systemctl enable sssd
mkdir -p /etc/sssd
touch $SSSD_CONF
truncate -s 0 $SSSD_CONF
