#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service


# We will configure user to be sssd

systemctl enable sssd
mkdir -p /etc/sssd/conf.d
echo -e "[sssd]\nuser = sssd" >> /etc/sssd/conf.d/ospp.conf
chmod 600 /etc/sssd/conf.d/ospp.conf
