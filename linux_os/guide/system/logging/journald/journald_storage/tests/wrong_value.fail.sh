#!/bin/bash
# platform = multi_platform_all
JOURNALD_CONFIG=/etc/systemd/journald.conf

if grep -q "^Compress" $JOURNALD_CONFIG; then
        sed -i "s/^Storage.*/Storage=volatile/" $JOURNALD_CONFIG
    else
        echo "Storage=volatile" >> $JOURNALD_CONFIG
fi
