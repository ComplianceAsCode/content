#!/bin/bash
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# variables = sshd_approved_macs=hmac-sha2-512,hmac-sha2-256,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

sshd_approved_macs=hmac-sha2-512,hmac-sha2-256,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
configfile=/etc/crypto-policies/back-ends/opensshserver.config
correct_value="-oMACs=${sshd_approved_macs}"

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

# Proceed when file exists
if [[ -f $configfile ]]; then
    sed -i -r "s/-oMACs=\S+/${correct_value}/" $configfile
else
    echo "${correct_value}" > "$configfile"
fi
