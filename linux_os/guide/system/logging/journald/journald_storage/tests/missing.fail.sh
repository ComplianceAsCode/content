#!/bin/bash
# platform = multi_platform_all

JOURNALD_CONFIG=/etc/systemd/journald.conf

if grep -q "^Storage" $JOURNALD_CONFIG; then
        sed -i "s/^Storage.*//" $JOURNALD_CONFIG
fi
