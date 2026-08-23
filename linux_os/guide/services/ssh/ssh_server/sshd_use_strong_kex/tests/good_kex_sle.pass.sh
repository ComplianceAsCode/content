#!/bin/bash
# platform = multi_platform_sle,multi_platform_ubuntu
# variables = sshd_strong_kex=diffie-hellman-group14-sha256

source include.sh
echo "KexAlgorithms diffie-hellman-group14-sha256" >> "{{{ sshd_main_config_file }}}"
