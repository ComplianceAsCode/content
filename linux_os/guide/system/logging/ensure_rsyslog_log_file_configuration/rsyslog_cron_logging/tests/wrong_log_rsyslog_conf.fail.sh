#!/bin/bash
# packages = rsyslog
source setup.sh

# Add cron.* that logs into wrong file
echo "cron.*        /tmp/log/cron" >> $RSYSLOG_CONF
