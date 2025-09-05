#!/bin/bash
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_stig

configfile=/etc/crypto-policies/back-ends/opensshserver.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

# If file exists, remove it
test -f $configfile && rm -f $configfile
