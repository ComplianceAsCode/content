#!/bin/bash

RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FILES='/etc/rsyslog.d/*'

# Ensure that rsyslog.conf exists and rsyslog.d folder doesn't contain any file with action
touch $RSYSLOG_CONF
for rsyslog_d_file in $RSYSLOG_D_FILES
do
	sed -i '/^[[:space:]]*action\.\*/d' $rsyslog_d_file
done

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="x509/name" StreamDriverMode="1")' >> "$RSYSLOG_CONF"
