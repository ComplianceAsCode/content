#!/bin/bash
# platform = multi_platform_ubuntu
# packages = aide

FILE=/etc/default/aide

if grep -q "^SILENTREPORTS=" $FILE; then
    sed -i "s/^SILENTREPORTS=.*$/SILENTREPORTS=wrong/g" $FILE
else
    echo "SILENTREPORTS=wrong" >> $FILE
fi

