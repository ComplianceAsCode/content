#!/bin/bash
# packages = rsyslog

RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FILES='/etc/rsyslog.d/*'

# Ensure that rsyslog.conf exists and rsyslog.d folder doesn't contain any file with cron.*
touch $RSYSLOG_CONF
for rsyslog_d_file in $RSYSLOG_D_FILES
do
	sed -i '/^[[:space:]]*cron\.\*/d' $rsyslog_d_file
done

echo 'cron.* action(Name="local-cron" Type="omfile" FileCreateMode="0600" FileOwner="root" FileGroup="root" File="/var/log/cron")' >> "$RSYSLOG_CONF"
