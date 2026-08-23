#!/bin/bash

SECURITY_LIMITS_FILE="/etc/security/limits.conf"
DROPIN_DIR="/etc/security/limits.d"
DROPIN_FILE="$DROPIN_DIR/wrong_drop-in.conf"

if grep -qE '\s*\*\s+hard\s+core' $SECURITY_LIMITS_FILE; then
        sed -ir 's/(hard\s+core\s+)(-?[[:digit:]]+|[[:alnum:]]+)/\1 0/' $SECURITY_LIMITS_FILE
else
        sed -i '$ a *        hard       core      0' $SECURITY_LIMITS_FILE
fi

mkdir -p "$DROPIN_DIR"
echo "*     hard   core    unlimited" >> $DROPIN_FILE
