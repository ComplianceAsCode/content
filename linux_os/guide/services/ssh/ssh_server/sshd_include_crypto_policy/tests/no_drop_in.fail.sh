#!/bin/bash
# remediation = none
# platform = multi_platform_all

sed -i '/Include/d' /etc/ssh/sshd_config

if ! grep -q "Include /etc/crypto-policies/back-ends/opensshserver.config" /etc/ssh/sshd_config.d/*.conf /etc/ssh/sshd_config; then
  echo "Include /etc/crypto-policies/back-ends/opensshserver.config" >> /etc/ssh/sshd_config.d/50-redhat.conf
fi
