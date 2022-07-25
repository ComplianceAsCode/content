#!/bin/bash
# packages = libreswan
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9


cp ipsec.conf /etc
config_file="/etc/ipsec.conf"
crypto="/etc/crypto-policies/back-ends/libreswan.config"
if grep -qP "^\s*include\s+$crypto" "$config_file" ; then
    sed -i "s%\s*include\s\+$crypto%#include $crypto%" "$config_file"
else
    echo "#include /etc/crypto-policies/back-ends/libreswan.config" >> "$config_file"
fi
