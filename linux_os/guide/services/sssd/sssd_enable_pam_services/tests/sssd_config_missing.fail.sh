#!/bin/bash
# packages = sssd-common
# remediation = none

# SSSD configuration files are expected to be created manually since the configuration can
# be different for each site. Therefore, if there is no configuration files previously created
# in the system, this rule will report "not applicable".
SSSD_CONF_FILE="/etc/sssd/sssd.conf"
SSSD_CONF_DIR_FILES="/etc/sssd/conf.d/*.conf"

rm -rf $SSSD_CONF_FILE $SSSD_CONF_DIR_FILES
