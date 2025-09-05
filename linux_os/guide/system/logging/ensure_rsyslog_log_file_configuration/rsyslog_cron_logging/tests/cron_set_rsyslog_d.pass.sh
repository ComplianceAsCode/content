#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cui, xccdf_org.ssgproject.content_profile_ospp
. set_cron_logging.sh

RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FOLDER='/etc/rsyslog.d'
RSYSLOG_D_FILE=$RSYSLOG_D_FOLDER'/test'

# Ensure that rsyslog.d folder exists and contains our 'test' file
mkdir -p $RSYSLOG_D_FOLDER
touch $RSYSLOG_D_FILE

sed -i '/^[[:space:]]*cron\.\*/d' $RSYSLOG_CONF

set_cron_logging $RSYSLOG_D_FILE
