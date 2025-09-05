#!/bin/bash

CONF_FILE="/etc/security/pwquality.conf"

sed -i "/^.*minlen\s*=.*/d" "$CONF_FILE"
