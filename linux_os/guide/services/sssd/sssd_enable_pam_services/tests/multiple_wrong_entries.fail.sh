#!/bin/bash
# packages = sssd-common

SSSD_CONF_FILE="/etc/sssd/sssd.conf"
SSSD_CONF_DIR_FILE="/etc/sssd/conf.d/sssd.conf"
SSSD_CONF_DIR_FILES="/etc/sssd/conf.d/*.conf"

rm -rf $SSSD_CONF_FILE $SSSD_CONF_DIR_FILES

for file in $SSSD_CONF_FILE $SSSD_CONF_DIR_FILE; do
    cp wrong_sssd.conf $file
done

cat <<EOF > "/etc/sssd/conf.d/sssd_custom.conf"
[sssd]
services = nss
domains = shadowutils

[nss]

[pam]
services = pam

[domain/shadowutils]
id_provider = ldap

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
