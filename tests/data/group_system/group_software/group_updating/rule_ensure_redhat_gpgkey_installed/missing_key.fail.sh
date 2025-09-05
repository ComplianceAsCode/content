#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

# remove all available keys

KEYS=$(rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\n')

if [ $? = 0 ]; then
    for KEY in $KEYS; do
    rpm -e $KEY
    done
fi
