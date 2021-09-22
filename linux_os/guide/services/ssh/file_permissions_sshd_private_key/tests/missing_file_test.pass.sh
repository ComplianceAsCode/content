#!/bin/bash
#

mkdir -p /etc/ssh/keys
mv /etc/ssh/*_key /etc/ssh/keys
sed -i "s#HostKey /etc/ssh/#HostKey /etc/ssh/keys/#g" sshd_config
systemctl restart sshd
