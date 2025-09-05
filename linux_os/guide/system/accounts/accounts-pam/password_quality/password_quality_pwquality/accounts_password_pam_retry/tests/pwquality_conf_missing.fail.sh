#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

CONF_FILE="/etc/security/pwquality.conf"

sed -i "/^.*retry\s*=.*/d" "$CONF_FILE"
