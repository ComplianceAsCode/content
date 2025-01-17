#!/bin/bash
# packages = sssd-common

SSSD_CONF_FILE="/etc/sssd/sssd.conf"
SSSD_CONF_DIR_FILES="/etc/sssd/conf.d/*.conf"

rm -rf $SSSD_CONF_FILE $SSSD_CONF_DIR_FILES

cat <<EOF > $SSSD_CONF_FILE
[sssd]
services = nss,pam
[pam]
example1 = abc
EOF
