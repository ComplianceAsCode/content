#!/bin/bash
# packages = libreswan
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8


cp ipsec.conf /etc
config_file="/etc/ipsec.conf"
if ! grep -P '^\s*include\s+/etc/crypto-policies/back-ends/libreswan.config\s*(?:#.*)?$' "$config_file" ; then
    echo "include /etc/crypto-policies/back-ends/libreswan.config" >> "$config_file"
fi
