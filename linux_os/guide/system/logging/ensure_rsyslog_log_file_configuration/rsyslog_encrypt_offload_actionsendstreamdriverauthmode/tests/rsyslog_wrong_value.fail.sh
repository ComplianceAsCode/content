#!/bin/bash
# packages = rsyslog
source setup.sh

echo "\$ActionSendStreamDriverAuthMode 0" >> $RSYSLOG_CONF
