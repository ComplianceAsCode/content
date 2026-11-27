#!/bin/bash
#
# platform = multi_platform_fedora

# remove all available keys

KEYS=$(rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\n')

if [ $? = 0 ]; then
    for KEY in $KEYS; do
    rpm -e $KEY
    done
fi

# Fedora 40 is past its end of life, so its key is not a supported one.
KEY="RPM-GPG-KEY-fedora-40-primary"

# From Fedora 45, the keys are in /usr/share/pki/rpm-gpg instead of /etc/pki/rpm-gpg.
if [ -f "/usr/share/pki/rpm-gpg/${KEY}" ]; then
    rpm --import "/usr/share/pki/rpm-gpg/${KEY}"
else
    rpm --import "/etc/pki/rpm-gpg/${KEY}"
fi
