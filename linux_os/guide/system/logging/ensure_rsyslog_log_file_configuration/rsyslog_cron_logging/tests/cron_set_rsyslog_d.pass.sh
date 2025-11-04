#!/bin/bash
# packages = rsyslog
source setup.sh

echo 'cron.*    /var/log/cron' >> $RSYSLOG_D_CONF
