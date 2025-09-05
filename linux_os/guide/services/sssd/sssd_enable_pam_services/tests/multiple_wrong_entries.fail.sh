#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service
#

rm -rf /etc/sssd/conf.d/
mkdir -p /etc/sssd/conf.d/
SSSD_CONF="/etc/sssd/conf.d/sssd.conf"

cp wrong_sssd.conf $SSSD_CONF

SSSD_CONF="/etc/sssd/sssd.conf"
cp wrong_sssd.conf $SSSD_CONF

SSSD_CONF="/etc/sssd/sssd_custom.conf"
cat <<EOF > $SSSD_CONF
[sssd]
services = nss
domains = shadowutils

[nss]

[pam]
services = pam

[domain/shadowutils]
id_provider = files

auth_provider = proxy
proxy_pam_target = sssd-shadowutils

proxy_fast_alias = True

[sssd]
services = abc,cde

[sssd]
services = pam
param1 = pam
services = abc,cde
EOF
