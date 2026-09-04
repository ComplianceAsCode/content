#!/bin/bash
# platform = multi_platform_sle
source common.sh

echo "Ciphers $sshd_approved_ciphers" >> "{{{ sshd_config_dir }}}/00-test.conf"
echo "Ciphers weak-cipher" >> "{{{ sshd_config_dir }}}/01-test.conf"
