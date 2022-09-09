#!/bin/bash
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,multi_platform_fedora
# profiles = xccdf_org.ssgproject.content_profile_stig

sshd_approved_macs=hmac-sha2-512,hmac-sha2-256
configfile=/etc/crypto-policies/back-ends/openssh.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

if [[ -f $configfile ]]; then
    sed -i "s/^.*MACs.*$/#MACs ${sshd_approved_macs}/" $configfile
else
    echo "#MACs ${sshd_approved_macs}" > "$configfile"
fi
