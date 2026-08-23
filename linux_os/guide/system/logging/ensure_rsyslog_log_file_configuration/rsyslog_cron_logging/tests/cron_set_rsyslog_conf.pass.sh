#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_cron_logging() }}}

echo 'cron.*    /var/log/cron' >> $RSYSLOG_CONF
