#!/bin/bash
# packages = rsyslog
source setup.sh

echo "\$ActionSendStreamDriverAuthMode x509/certvalid" >> $RSYSLOG_D_CONF
