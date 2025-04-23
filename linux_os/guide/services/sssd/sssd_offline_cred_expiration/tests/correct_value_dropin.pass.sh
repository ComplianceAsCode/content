#!/bin/bash
{{%- if product in ["rhel8"] %}}
# platform = Not Applicable
{{%- endif %}}
# packages = sssd

source common.sh

export SSSD_CONF=/etc/sssd/conf.d/cac.conf

echo -e "[pam]\noffline_credentials_expiration = 1" >> $SSSD_CONF

echo -e "[domain/EXAMPLE]\ncache_credentials = true" >> $SSSD_CONF
