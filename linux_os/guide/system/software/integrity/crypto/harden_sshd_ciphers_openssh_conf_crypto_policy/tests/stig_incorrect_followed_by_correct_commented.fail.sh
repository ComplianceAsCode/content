#!/bin/bash
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,multi_platform_fedora
# profiles = xccdf_org.ssgproject.content_profile_stig

sshd_approved_ciphers=aes256-ctr,aes192-ctr,aes128-ctr
incorrect_sshd_approved_ciphers=aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr
configfile=/etc/crypto-policies/back-ends/openssh.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

if [[ -f $configfile ]]; then
    sed -i "s/^.*Ciphers.*$/Ciphers ${incorrect_sshd_approved_ciphers}/" $configfile
else
    echo "Ciphers ${incorrect_sshd_approved_ciphers}" > "$configfile"
fi

# follow up with correct value
echo "#Ciphers ${sshd_approved_ciphers}" >> $configfile
