#!/bin/bash

SSSD_CONF="/etc/sssd/sssd.conf"

yum -y install /usr/lib/systemd/system/sssd.service
systemctl enable sssd
mkdir -p /etc/sssd
touch $SSSD_CONF
truncate -s 0 $SSSD_CONF
