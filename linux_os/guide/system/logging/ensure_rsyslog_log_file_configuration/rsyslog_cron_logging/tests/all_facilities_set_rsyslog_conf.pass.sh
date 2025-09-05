#!/bin/bash
# platform = Oracle Linux 8
. set_cron_logging.sh

RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FOLDER='/etc/rsyslog.d'
RSYSLOG_D_FILES='/etc/rsyslog.d/*'

mkdir $RSYSLOG_D_FOLDER
rm $RSYSLOG_D_FILES
truncate -s 0 $RSYSLOG_CONF

echo '*.*    /var/log/messages' >> $RSYSLOG_CONF
