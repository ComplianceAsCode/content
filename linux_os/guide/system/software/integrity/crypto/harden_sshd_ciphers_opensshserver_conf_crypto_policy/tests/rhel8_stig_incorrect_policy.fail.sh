#!/bin/bash
# platform = Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_stig

configfile=/etc/crypto-policies/back-ends/opensshserver.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

if [[ -f $configfile ]]; then
    sed -i -r "s/-oCiphers=\S+/-oCiphers=aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes256-cbc/" $configfile
else
    echo "-oCiphers=aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes256-cbc" > "$configfile"
fi
