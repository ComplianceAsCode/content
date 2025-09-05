#!/bin/bash
# platform = Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_stig

sshd_approved_ciphers=aes256-ctr,aes192-ctr,aes128-ctr
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
