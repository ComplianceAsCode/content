#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_cron_logging() }}}

# Add cron.* that logs into wrong file
cat << EOF >> "$RSYSLOG_CONF"
cron.* action(
    name="local-cron"
    type="omfile"
    fileCreateMode="0600"
    fileOwner="root"
    fileGroup="root"
    file="/tmp/log/cron"
)
EOF
