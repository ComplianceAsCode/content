#!/bin/bash
# platform = Red Hat Enterprise Linux 8,multi_platform_ol,multi_platform_fedora
# variables = sshd_approved_macs=hmac-sha2-512,hmac-sha2-256,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

sshd_approved_macs=hmac-sha2-512,hmac-sha2-256,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

configfile=/etc/crypto-policies/back-ends/openssh.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

if [[ -f $configfile ]]; then
    sed -i "s/^.*MACs.*$/MACs ${sshd_approved_macs}/" $configfile
else
    echo "MACs ${sshd_approved_macs}" > "$configfile"
fi

# follow up with incorrect
echo "#MACs hmac-sha2-256-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha1,umac-128@openssh.com,hmac-sha2-512" >> $configfile
