#!/bin/bash

# Use this script to ensure the rsyslog directory structure and rsyslog conf file
# exist in the test env.
RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FOLDER='/etc/rsyslog.d'
RSYSLOG_D_CONF='/etc/rsyslog.d/encrypt.conf'

# Ensure directory structure exists (useful for container based testing)
test -f $RSYSLOG_CONF || touch $RSYSLOG_CONF

mkdir -p $RSYSLOG_D_FOLDER

# remove DefaultNetstreamDriver entries
sed -i '/^[[:space:]]*\$DefaultNetstreamDriver/d' $RSYSLOG_CONF
find $RSYSLOG_D_FOLDER -type f -name "*.conf" -exec sed -i '/^[[:space:]]*\$DefaultNetstreamDriver/d' {} +
# remove all multilined and onelined RainerScript entries
sed -i '/^[[:space:]]*global\(/ { :a; N; /\)/!ba; /DefaultNetstreamDriver/d }' $RSYSLOG_CONF
find $RSYSLOG_D_FOLDER -type f -name "*.conf" -exec sed -i '/^[[:space:]]*global\(/ { :a; N; /\)/!ba; /DefaultNetstreamDriver/d }' {} +