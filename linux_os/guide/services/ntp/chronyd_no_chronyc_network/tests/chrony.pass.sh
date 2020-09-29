#!/bin/bash
#

yum install -y chrony
systemctl enable chronyd.service

echo "cmdport 0" >> /etc/chrony.conf
