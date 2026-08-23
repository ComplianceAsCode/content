#!/bin/bash
#
{{% if "rhel" in families  and major_version_ordinal >= 10 %}}
# packages = sequoia-sq
{{% endif %}}

# remove all available keys

KEYS=$(rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\n')

if [ $? = 0 ]; then
    for KEY in $KEYS; do
    rpm -e $KEY
    done
fi
