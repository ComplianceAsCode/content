#!/bin/bash
# packages = bash

# This TS is a regression test for https://github.com/ComplianceAsCode/content/issues/11937

sed -i '/umask/d' /etc/bashrc
echo "    [ \`umask\` -eq 0 ] && umask 027022" >> /etc/bashrc
umask 000
