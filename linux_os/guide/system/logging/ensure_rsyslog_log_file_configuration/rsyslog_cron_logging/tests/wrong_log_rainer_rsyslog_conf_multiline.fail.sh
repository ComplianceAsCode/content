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

# If there's cron.* line, then remove it
sed -i '/^[[:space:]]*cron\.\*/d' $RSYSLOG_CONF
# Add cron.* that logs into wrong file
cat << EOF >> "$RSYSLOG_CONF"
cron.* action(
    name="local-cron"
    type="omfile"
    fileCreateMode="0600"
    fileOwner="root"
    fileGroup="root"
    file="/tmp/log/cron"
)
EOF
