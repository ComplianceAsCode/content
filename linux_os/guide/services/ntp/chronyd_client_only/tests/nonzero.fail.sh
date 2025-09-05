#!/bin/bash
# packages = chrony
#

systemctl enable chronyd.service

echo "port 124" >> /etc/chrony.conf
