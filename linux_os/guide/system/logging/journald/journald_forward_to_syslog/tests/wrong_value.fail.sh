#!/bin/bash
# platform = multi_platform_all
JOURNALD_CONFIG=/etc/systemd/journald.conf

if grep -q "^ForwardToSyslog" $JOURNALD_CONFIG; then
        sed -i "s/^ForwardToSyslog.*/ForwardToSyslog=no/" $JOURNALD_CONFIG
    else
        echo "ForwardToSyslog=no" >> $JOURNALD_CONFIG
fi
