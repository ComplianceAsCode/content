#!/bin/bash
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,multi_platform_fedora
# variables = sshd_approved_ciphers=aes256-ctr,aes192-ctr,aes128-ctr

configfile=/etc/crypto-policies/back-ends/openssh.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

echo "" > $configfile
