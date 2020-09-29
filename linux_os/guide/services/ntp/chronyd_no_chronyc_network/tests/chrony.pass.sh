#!/bin/bash
# packages = chrony
#

systemctl enable chronyd.service

echo "cmdport 0" >> /etc/chrony.conf
