#!/bin/bash
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,multi_platform_rhel

rm -f /etc/krb5.conf.d/crypto-policies
ln -s /etc/crypto-policies/back-ends/krb5.config /etc/krb5.conf.d/crypto-policies
