#!/bin/bash
# platform = multi_platform_sle,multi_platform_ubuntu
# variables = sshd_strong_kex=diffie-hellman-group14-sha256

sed -i 's/^\s*KexAlgorithms\s.*//i' /etc/ssh/sshd_config
echo "KexAlgorithms diffie-hellman-group14-sha256" >> /etc/ssh/sshd_config
