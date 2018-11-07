#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_standard

cp ipsec.conf /etc
config_file="/etc/ipsec.conf"
crypto="/etc/crypto-policies/back-ends/libreswan.config"
bad_crypto="/etc/crypto-ends/libreswan.config"
if grep -qP "^\s*include\s+$crypto" "$config_file" ; then
    sed -i "s%\s*include\s\+$crypto%include $bad_crypto%" "$config_file"
else
    echo "include $bad_crypto" >> "$config_file"
fi
