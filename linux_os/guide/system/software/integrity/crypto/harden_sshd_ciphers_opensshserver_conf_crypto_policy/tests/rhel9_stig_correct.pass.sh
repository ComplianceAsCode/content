#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# variables = sshd_approved_ciphers=aes256-gcm@openssh.com,aes256-ctr,aes128-gcm@openssh.com,aes128-ctr
# remediation = none

sshd_approved_ciphers=aes256-gcm@openssh.com,aes256-ctr,aes128-gcm@openssh.com,aes128-ctr

configfile=/etc/crypto-policies/back-ends/opensshserver.config
correct_value="Ciphers ${sshd_approved_ciphers}"

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

# Proceed when file exists
if [[ -f $configfile ]]; then
    sed -i -r "s/Ciphers\s+\S+/${correct_value}/" $configfile
else
    echo "${correct_value}" > "$configfile"
fi
