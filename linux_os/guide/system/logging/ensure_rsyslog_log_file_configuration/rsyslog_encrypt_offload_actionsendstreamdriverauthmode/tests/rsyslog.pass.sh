#!/bin/bash
# packages = rsyslog
source setup.sh

echo "\$ActionSendStreamDriverAuthMode x509/name" >> $RSYSLOG_CONF
