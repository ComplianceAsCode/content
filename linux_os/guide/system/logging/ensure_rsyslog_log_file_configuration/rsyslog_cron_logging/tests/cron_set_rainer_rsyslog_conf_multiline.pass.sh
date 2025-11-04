#!/bin/bash
# packages = rsyslog
source setup.sh

cat << EOF >> "$RSYSLOG_CONF"
cron.* action(
    name="local-cron"
    type="omfile"
    fileCreateMode="0600"
    fileOwner="root"
    fileGroup="root"
    file="/var/log/cron"
)
EOF
