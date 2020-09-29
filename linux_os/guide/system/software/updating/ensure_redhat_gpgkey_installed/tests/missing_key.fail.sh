#!/bin/bash
#

# remove all available keys

KEYS=$(rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\n')

if [ $? = 0 ]; then
    for KEY in $KEYS; do
    rpm -e $KEY
    done
fi
