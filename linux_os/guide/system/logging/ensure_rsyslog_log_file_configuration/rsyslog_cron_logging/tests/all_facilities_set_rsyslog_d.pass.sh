#!/bin/bash
# packages = rsyslog
# platform = multi_platform_ol
{{{ setup_rsyslog_cron_logging() }}}

rm "$RSYSLOG_D_FOLDER/*.conf"
truncate -s 0 $RSYSLOG_CONF

echo '*.*    /var/log/messages' >> $RSYSLOG_D_CONF
