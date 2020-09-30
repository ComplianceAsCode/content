#!/bin/bash
#

yum install -y chrony
systemctl enable chronyd.service

echo "cmdport 324" >> /etc/chrony.conf
