#!/bin/bash
# platform = Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_stig

configfile=/etc/crypto-policies/back-ends/opensshserver.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

if [[ -f $configfile ]]; then
    sed -i -r "s/-oMACs=\S+/-oMACs=hmac-sha2-256-etm@openssh.com,hmac-sha1-etm@openssh.com/" $configfile
else
    echo "-oMACs=hmac-sha2-256-etm@openssh.com,hmac-sha1-etm@openssh.com" > "$configfile"
fi
