#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_standard

yum install -y libreswan

cp ipsec.conf /etc
config_file="/etc/ipsec.conf"
crypto="/etc/crypto-policies/back-ends/libreswan.config"
if grep -qP "^\s*include\s+$crypto" "$config_file" ; then
    sed -i "s%\s*include\s\+$crypto%#include $crypto%" "$config_file"
else
    echo "#include /etc/crypto-policies/back-ends/libreswan.config" >> "$config_file"
fi
