#!/bin/bash
# packages = sssd
#

SSSD_CONF="/etc/sssd/sssd.conf"

rm -rf /etc/sssd/conf.d/
rm -f SSSD_CONF
cat <<EOF > $SSSD_CONF
[sssd]
services = nss,pam
[pam]
example1 = abc
EOF
