#!/bin/bash
# packages = openssh-clients
# check = sce

# Remove any existing SSH key pairs for all interactive users
for dir in $(awk -F: '$7 !~ /\/s?bin\/(false|nologin)/ {print $6}' /etc/passwd | sort -u); do
    for pubkey in $(find "${dir}/.ssh/" -type f -name '*.pub' 2>/dev/null); do
        rm -f "${pubkey}" "${pubkey%.pub}"
    done
done

# Create an SSH key pair with a passphrase for root
ssh-keygen -t rsa -b 2048 -f /root/.ssh/test_key -N "testpassphrase" -q
