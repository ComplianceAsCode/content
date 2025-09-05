#!/bin/bash
#

mkdir -p /etc/ssh/keys
mv /etc/ssh/*_key /etc/ssh/keys
sed -i "s#HostKey /etc/ssh/#HostKey /etc/ssh/keys/#g" /etc/ssh/sshd_config
systemctl restart sshd
rm -f /etc/ssh/*_key # systemctl restart sshd always regenerate keys in the /etc/ssh if they are not there
