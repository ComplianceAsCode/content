#!/bin/bash
# packages = rsyslog
source setup.sh

echo 'cron.* action(name="local-cron" type="omfile" FileCreateMode="0600" fileOwner="root" fileGroup="root" File="/var/log/cron")' >> "$RSYSLOG_D_CONF"
