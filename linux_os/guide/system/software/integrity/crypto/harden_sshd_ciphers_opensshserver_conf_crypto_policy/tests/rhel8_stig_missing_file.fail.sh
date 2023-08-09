#!/bin/bash
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# variables = sshd_approved_ciphers=aes256-ctr,aes192-ctr,aes128-ctr,aes256-gcm@openssh.com,aes128-gcm@openssh.com

configfile=/etc/crypto-policies/back-ends/opensshserver.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

# If file exists, remove it
test -f $configfile && rm -f $configfile
