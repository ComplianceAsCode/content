#!/bin/bash
# packages = {{{- ssgts_package("pam_pwquality") -}}}

CONF_FILE="/etc/security/pwquality.conf"

if grep -q "^.*minlen\s*=" "$CONF_FILE"; then
	sed -i "s/^.*minlen\s*=.*/minlen = 15/" "$CONF_FILE"
else
	echo "minlen = 15" >> "$CONF_FILE"
fi
