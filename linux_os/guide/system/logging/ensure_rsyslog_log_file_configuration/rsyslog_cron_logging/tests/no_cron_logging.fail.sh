#!/bin/bash
# packages = rsyslog
. remove_cron_logging.sh

RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FOLDER='/etc/rsyslog.d'

# Ensure that rsyslog.conf exists and rsyslog.d folder doesn't contain any file with legacy or multilined cron.* entry
touch $RSYSLOG_CONF
mkdir -p $RSYSLOG_D_FOLDER

remove_cron_logging
