#!/bin/bash
# platform = Not Applicable
# variables = sshd_approved_ciphers=aes256-ctr,aes192-ctr,aes128-ctr,aes256-gcm@openssh.com,aes128-gcm@openssh.com

configfile=/etc/crypto-policies/back-ends/opensshserver.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

# Get the last CRYPTO_POLICY line
last_crypto_policy=$(grep -E "^CRYPTO_POLICY='[^']+'" "$configfile" | tail -n 1)

# Generate a corrected version by replacing any -oCiphers= value
if grep -qPo '(-oCiphers=\S+)' <<< "$last_crypto_policy"; then
    fixed_crypto_policy=$(sed -E "s/-oCiphers=\S+[[:space:]]*//" <<< "$last_crypto_policy")
fi

echo -e "\n$fixed_crypto_policy" >> "$configfile"
