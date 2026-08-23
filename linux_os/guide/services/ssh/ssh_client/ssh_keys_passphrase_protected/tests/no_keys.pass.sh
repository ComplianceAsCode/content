#!/bin/bash
# packages = openssh-clients
# check = sce

# Remove any existing SSH key pairs for all interactive users
# Preserve authorized_keys and other non-key files so Automatus can still SSH in
for dir in $(awk -F: '$7 !~ /\/s?bin\/(false|nologin)/ {print $6}' /etc/passwd | sort -u); do
    for pubkey in $(find "${dir}/.ssh/" -type f -name '*.pub' 2>/dev/null); do
        rm -f "${pubkey}" "${pubkey%.pub}"
    done
done
