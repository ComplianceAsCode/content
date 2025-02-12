#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# variables = sshd_approved_ciphers=aes256-gcm@openssh.com,aes256-ctr,aes128-gcm@openssh.com,aes128-ctr
# remediation = none

configfile=/etc/crypto-policies/back-ends/opensshserver.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

if [[ -f $configfile ]]; then
    sed -i -r "s/Ciphers\s+\S+/Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes256-cbc/" $configfile
else
    echo "Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes256-cbc" > "$configfile"
fi
