#!/bin/bash
# packages = rsyslog
source setup.sh

echo 'cron.* action(Name="local-cron" Type="omfile" FileCreateMode="0600" FileOwner="root" FileGroup="root" File="/var/log/cron")' >> "$RSYSLOG_CONF"
