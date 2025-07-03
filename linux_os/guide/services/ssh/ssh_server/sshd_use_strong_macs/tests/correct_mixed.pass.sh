#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu,multi_platform_almalinux
# variables = sshd_strong_macs=hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512

sed -i 's/^\s*MACs\s.*//i' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* || true
echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha2-256-etm@openssh.com" >> /etc/ssh/sshd_config
