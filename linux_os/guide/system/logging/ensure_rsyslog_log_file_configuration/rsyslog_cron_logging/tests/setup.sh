#!/bin/bash

# Use this script to ensure the rsyslog directory structure and rsyslog conf file
# exist in the test env.
RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FOLDER='/etc/rsyslog.d'
RSYSLOG_D_CONF='/etc/rsyslog.d/cron.conf'

# Ensure directory structure exists (useful for container based testing)
test -f $RSYSLOG_CONF || touch $RSYSLOG_CONF

mkdir -p $RSYSLOG_D_FOLDER

# remove all multilined cron.* entries
sed -i '/^[[:space:]]*cron\.\*.*action(/,/)/d' $RSYSLOG_CONF
find $RSYSLOG_D_FOLDER -type f -name "*.conf" -exec sed -i '/^[[:space:]]*cron\.\*.*action(/,/)/d' {} +
# remove all legacy format and one line cron.* entries
sed -i '\|^\s*\*\.\*\s+/var/log/cron\s*$|d' $RSYSLOG_CONF
sed -i '/^[[:space:]]*cron\.\*/d' $RSYSLOG_CONF
find $RSYSLOG_D_FOLDER -type f -name "*.conf" -exec sed -i '\|^\s*\*\.\*\s+/var/log/cron\s*$' {} +
find $RSYSLOG_D_FOLDER -type f -name "*.conf" -exec sed -i '/^[[:space:]]*cron\.\*/d' {} +