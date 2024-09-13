#!/bin/bash
# packages = sssd-common
# remediation = none

SSSD_CONF_FILE="/etc/sssd/sssd.conf"
SSSD_CONF_DIR_FILES="/etc/sssd/conf.d/*.conf"

rm -rf $SSSD_CONF_FILE $SSSD_CONF_DIR_FILES
