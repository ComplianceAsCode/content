#!/bin/bash

SECURITY_LIMITS_FILE="/etc/security/limits.conf"

if grep -qE '\s*\*\s+hard\s+core' $SECURITY_LIMITS_FILE; then
        sed -ir 's/(hard\s+core\s+)[[:digit:]]+/\1 0/' $SECURITY_LIMITS_FILE
else
        sed -i '$ a *        hard       core      0' $SECURITY_LIMITS_FILE
fi
