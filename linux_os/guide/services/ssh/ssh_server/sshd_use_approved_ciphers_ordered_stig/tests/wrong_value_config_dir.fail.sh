#!/bin/bash

source common.sh

echo "Ciphers $sshd_approved_ciphers,weak-cipher" >> "{{{ sshd_config_dir }}}/00-test.conf"
