#!/bin/bash
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# variables = sshd_approved_ciphers=aes256-ctr,aes192-ctr,aes128-ctr,aes256-gcm@openssh.com,aes128-gcm@openssh.com

sshd_approved_ciphers=aes256-ctr,aes192-ctr,aes128-ctr,aes256-gcm@openssh.com,aes128-gcm@openssh.com

configfile=/etc/crypto-policies/back-ends/opensshserver.config
correct_value="-oCiphers=${sshd_approved_ciphers}"

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

# Proceed when file exists
if [[ -f $configfile ]]; then
    sed -i -r "s/-oCiphers=\S+/${correct_value}/" $configfile
else
    echo "${correct_value}" > "$configfile"
fi
