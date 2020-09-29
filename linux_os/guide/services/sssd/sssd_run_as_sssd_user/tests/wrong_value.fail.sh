#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service


systemctl enable sssd
mkdir -p /etc/sssd/conf.d
echo -e "[sssd]\nuser = sssd\nuser = bob" >> /etc/sssd/conf.d/ospp.conf
chmod 600 /etc/sssd/conf.d/ospp.conf
