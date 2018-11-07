#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_standard

cp ipsec.conf /etc
config_file="/etc/ipsec.conf"
if ! grep -P '^\s*include\s+/etc/crypto-policies/back-ends/libreswan.config\s*(?:|(?:#.*))$' "$config_file" ; then
    echo "include /etc/crypto-policies/back-ends/libreswan.config" >> "$config_file"
fi
