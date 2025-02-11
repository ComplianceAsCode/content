#!/bin/bash
# remediation = none
# platform = multi_platform_all

sed -i '/Include \/etc\/crypto-policies\/back-ends\/opensshserver.config/d' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf
echo "Include /etc/crypto-policies/back-ends/opensshserver.config" >> /etc/ssh/sshd_config.d/50-redhat.conf

if ! grep -q "Include /etc/ssh/sshd_config.d/*.conf" /etc/ssh/sshd_config; then
  echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/sshd_config
fi
