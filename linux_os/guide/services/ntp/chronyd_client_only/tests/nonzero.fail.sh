#!/bin/bash
#

yum install -y chrony
systemctl enable chronyd.service

echo "port 124" >> /etc/chrony.conf
