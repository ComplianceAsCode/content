#!/bin/bash
# packages = rsyslog
source setup.sh

echo "\$ActionSendStreamDriverMode 0" >> $RSYSLOG_D_CONF
