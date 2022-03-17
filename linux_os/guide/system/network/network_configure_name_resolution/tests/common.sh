#!/bin/bash

NSSWITCHFILE=/etc/nsswitch.conf
RESOLVFILE=/etc/resolv.conf

sed -r -i 's/(^\s*hosts:.*?)\bdns\b\s*(.*)/\1\2/g' "$NSSWITCHFILE"

truncate -s 0 "$RESOLVFILE"
