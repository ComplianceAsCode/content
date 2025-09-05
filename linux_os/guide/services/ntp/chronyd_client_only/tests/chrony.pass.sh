#!/bin/bash
# packages = chrony
#

systemctl enable chronyd.service

echo "port 0" >> /etc/chrony.conf
