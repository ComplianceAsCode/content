#!/bin/bash
# platform = multi_platform_all
JOURNALD_CONFIG=/etc/systemd/journald.conf

if grep -q "^Compress" $JOURNALD_CONFIG; then
        sed -i "s/^Compress.*/Compress=no/" $JOURNALD_CONFIG
    else
        echo "Compress=no" >> $JOURNALD_CONFIG
fi
