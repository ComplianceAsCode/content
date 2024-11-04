#!/bin/bash

sed -i '/Include/d' /etc/ssh/sshd_config

if [ grep -q "Include /etc/ssh/sshd_config.d/*.conf" /etc/ssh/sshd_config -ne 0 ]; then
  echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/ssh_config
fi
