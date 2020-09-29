#!/bin/bash
# packages = chrony
#

systemctl enable chronyd.service

echo "cmdport 324" >> /etc/chrony.conf
