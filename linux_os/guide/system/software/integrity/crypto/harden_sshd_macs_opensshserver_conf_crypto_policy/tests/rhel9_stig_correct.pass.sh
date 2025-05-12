#!/bin/bash
# platform = Oracle Linux 9,Red Hat Enterprise Linux 9
# variables = sshd_approved_macs=hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256

sshd_approved_macs=hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256

configfile=/etc/crypto-policies/back-ends/opensshserver.config
correct_value="MACs ${sshd_approved_macs}"

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

# Proceed when file exists
if [[ -f $configfile ]]; then
    sed -i -r "s/^(?!\s*#)MACs\s+\S+/${correct_value}/" $configfile
else
    echo "${correct_value}" > "$configfile"
fi
