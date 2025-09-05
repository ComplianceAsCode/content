#!/bin/bash
# packages = sssd
#

SSSD_SERVICES_REGEX_SHORT="^[[:space:]]*services.*$"
SSSD_CONF="/etc/sssd/sssd.conf"

rm -rf /etc/sssd/conf.d/
rm -f SSSD_CONF
cat <<EOF > $SSSD_CONF
[sssd]
section1 = key
section2 = nss
[pam]
example1 = abc
EOF
