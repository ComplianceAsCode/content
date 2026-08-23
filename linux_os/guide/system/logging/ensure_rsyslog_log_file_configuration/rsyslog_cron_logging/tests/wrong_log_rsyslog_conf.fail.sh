#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_cron_logging() }}}

# Add cron.* that logs into wrong file
echo "cron.*        /tmp/log/cron" >> $RSYSLOG_CONF
