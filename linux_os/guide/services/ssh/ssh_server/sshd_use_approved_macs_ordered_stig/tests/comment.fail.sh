#!/bin/bash

source common.sh

echo "# ciphers MACs $sshd_approved_macs" >> /etc/ssh/sshd_config
