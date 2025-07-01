#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux, multi_platform_ubuntu

{{%- if sshd_distributed_config == "true" %}}
mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/test.conf
sed -i 's/^\s*Ciphers\s/# &/i' /etc/ssh/sshd_config
sed -i 's/^\s*Ciphers\s/# &/i' /etc/ssh/sshd_config.d/test.conf
{{% endif %}}
