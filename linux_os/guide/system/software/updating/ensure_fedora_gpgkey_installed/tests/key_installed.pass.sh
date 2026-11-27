#!/bin/bash
#
# platform = multi_platform_fedora

KEY="RPM-GPG-KEY-fedora-$(rpm -E %fedora)-primary"

# From Fedora 45, the keys are in /usr/share/pki/rpm-gpg instead of /etc/pki/rpm-gpg.
if [ -f "/usr/share/pki/rpm-gpg/${KEY}" ]; then
    rpm --import "/usr/share/pki/rpm-gpg/${KEY}"
else
    rpm --import "/etc/pki/rpm-gpg/${KEY}"
fi
