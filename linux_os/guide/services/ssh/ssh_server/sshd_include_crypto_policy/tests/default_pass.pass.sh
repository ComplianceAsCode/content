#!/bin/bash

if ! grep -q "Include /etc/crypto-policies/back-ends/opensshserver.config" /etc/ssh/ssh_config.d/*.conf /etc/ssh/sshd_config; then
  echo "Include /etc/crypto-policies/back-ends/opensshserver.config" >> /etc/ssh/ssh_config.d/50-redhat.conf
fi

if ! grep -q "Include /etc/ssh/sshd_config.d/*.conf" /etc/ssh/sshd_config; then
  echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/ssh_config
fi
