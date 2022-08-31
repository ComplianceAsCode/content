#!/bin/bash
# platform = Oracle Linux 7,Oracle Linux 8
. set_cron_logging.sh

RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FOLDER='/etc/rsyslog.d'
RSYSLOG_D_FILE=$RSYSLOG_D_FOLDER'/test'

mkdir -p $RSYSLOG_D_FOLDER
rm "$RSYSLOG_D_FOLDER/*"
truncate -s 0 $RSYSLOG_CONF

echo '*.*    /var/log/messages' >> $RSYSLOG_D_FILE
