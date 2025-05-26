#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_almalinux

source common.sh

echo "Ciphers aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config
