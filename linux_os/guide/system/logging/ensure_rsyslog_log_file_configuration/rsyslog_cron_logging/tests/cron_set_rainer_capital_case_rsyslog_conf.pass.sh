#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_cron_logging() }}}

echo 'cron.* action(Name="local-cron" Type="omfile" FileCreateMode="0600" FileOwner="root" FileGroup="root" File="/var/log/cron")' >> "$RSYSLOG_CONF"
