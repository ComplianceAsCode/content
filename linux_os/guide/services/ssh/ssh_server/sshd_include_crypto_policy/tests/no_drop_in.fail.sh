#!/bin/bash

# this is done because the remediation will reset the /etc/ssh/sshd_config file
# which is modified by Automatus so that root can log in.
# This prevents Automatus from logging in for final scan.
echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/99-automatus.conf

sed -i '/Include/d' /etc/ssh/sshd_config

if ! grep -q "Include /etc/ssh/sshd_config.d/*.conf" /etc/ssh/sshd_config; then
  echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/ssh_config
fi
