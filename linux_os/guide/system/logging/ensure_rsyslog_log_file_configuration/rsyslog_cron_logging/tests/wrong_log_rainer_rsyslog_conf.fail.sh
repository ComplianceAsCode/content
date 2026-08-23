#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_cron_logging() }}}

# Add cron.* that logs into wrong file
echo 'cron.* action(name="local-cron" type="omfile" fileCreateMode="0600" fileOwner="root" fileGroup="root" file="/tmp/log/cron")' >> "$RSYSLOG_CONF"
