#!/bin/bash
# platform = multi_platform_all
JOURNALD_CONFIG=/etc/systemd/journald.conf

if grep -q "^Compress" $JOURNALD_CONFIG; then
        sed -i "s/^Compress.*/Compress=yes/" $JOURNALD_CONFIG
    else
        echo "Compress=yes" >> $JOURNALD_CONFIG
fi
