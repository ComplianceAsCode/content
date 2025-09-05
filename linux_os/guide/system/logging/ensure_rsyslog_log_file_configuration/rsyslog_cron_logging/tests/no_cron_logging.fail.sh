#!/bin/bash

RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FILES='/etc/rsyslog.d/*'

# At least ensure that rsyslog.conf exist
touch $RSYSLOG_CONF

sed -i '/^[[:space:]]*cron\.\*/d' $RSYSLOG_CONF
for rsyslog_d_file in $RSYSLOG_D_FILES
do
	sed -i '/^[[:space:]]*cron\.\*/d' $rsyslog_d_file
done
