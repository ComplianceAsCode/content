#!/bin/bash
# platform = multi_platform_sle
source common.sh

echo "Ciphers $sshd_approved_ciphers" >> "{{{ sshd_main_config_file }}}"
echo "Ciphers weak-cipher" >> "{{{ sshd_main_config_file }}}"
