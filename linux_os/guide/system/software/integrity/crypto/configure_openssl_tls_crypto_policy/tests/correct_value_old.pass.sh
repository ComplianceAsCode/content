#!/bin/bash
# platform = Oracle Linux 8

{{{ bash_package_install("yum-utils") }}}

yum-config-manager --enable ol8_u4_baseos_base

yum downgrade -y crypto-policies-20210209-1.gitbfb6bed.el8_3

configfile=/etc/crypto-policies/back-ends/opensslcnf.config

echo "MinProtocol = TLSv1.2" > "$configfile"