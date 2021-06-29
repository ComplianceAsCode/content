#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_stig

sshd_approved_ciphers=aes256-ctr,aes192-ctr,aes128-ctr
configfile=/etc/crypto-policies/back-ends/openssh.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

if [[ -f $configfile ]]; then
    sed -i "s/^.*Ciphers.*$/#Ciphers ${sshd_approved_ciphers}/" $configfile
else
    echo "#Ciphers ${sshd_approved_ciphers}" > "$configfile"
fi
