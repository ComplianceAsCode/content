#!/bin/bash
# packages = sssd

rm -rf "/etc/sssd/conf.d/"
rm -f "/etc/sssd/sssd.conf"
mkdir -p "/etc/sssd/conf.d/"
cat <<EOF > "/etc/sssd/conf.d/sssd.conf"
[sssd]
services = nss,pam
[pam]
example1 = abc
EOF
