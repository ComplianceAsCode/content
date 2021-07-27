#!/bin/bash
# packages = {{{- ssgts_package("pam_pwquality") -}}}

CONF_FILE="/etc/security/pwquality.conf"

sed -i "/^.*minlen\s*=.*/d" "$CONF_FILE"
