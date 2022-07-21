#!/bin/bash
# packages = libreswan
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9


cp ipsec.conf /etc
config_file="/etc/ipsec.conf"
if ! grep -P '^\s*include\s+/etc/crypto-policies/back-ends/libreswan.config\s*(?:#.*)?$' "$config_file" ; then
    echo "include /etc/crypto-policies/back-ends/libreswan.config" >> "$config_file"
fi
