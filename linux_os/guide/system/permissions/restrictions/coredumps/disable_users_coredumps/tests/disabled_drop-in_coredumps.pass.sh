#!/bin/bash

SECURITY_LIMITS_FILE="/etc/security/limits.conf"
DROPIN_DIR="/etc/security/limits.d"
DROPIN_FILE="$DROPIN_DIR/correct_drop-in.conf"

if grep -qE '\s*\*\s+hard\s+core' $SECURITY_LIMITS_FILE; then
        sed -ir 's/(hard\s+core\s+)(-?[[:digit:]]+|[[:alnum:]]+)/\1 1/' $SECURITY_LIMITS_FILE
else
        sed -i '$ a *        hard       core      1' $SECURITY_LIMITS_FILE
fi

mkdir -p "$DROPIN_DIR"
echo "*     hard   core    0" >> $DROPIN_FILE
