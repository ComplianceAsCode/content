#!/bin/bash
# packages = sssd-common

SSSD_CONF_FILE="/etc/sssd/sssd.conf"
SSSD_CONF_DIR_FILE="/etc/sssd/conf.d/sssd.conf"
SSSD_CONF_DIR_FILES="/etc/sssd/conf.d/*.conf"

rm -rf $SSSD_CONF_FILE $SSSD_CONF_DIR_FILES

for file in $SSSD_CONF_FILE $SSSD_CONF_DIR_FILE; do
    cp wrong_sssd.conf $file
done
