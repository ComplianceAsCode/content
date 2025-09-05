#!/bin/bash
# packages = libreswan
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8


cp ipsec.conf /etc
config_file="/etc/ipsec.conf"
crypto="/etc/crypto-policies/back-ends/libreswan.config"
if grep -qP "^\s*include\s+$crypto" "$config_file" ; then
    sed -i "\%\s*include\s\+$crypto%d" "$config_file"
fi
