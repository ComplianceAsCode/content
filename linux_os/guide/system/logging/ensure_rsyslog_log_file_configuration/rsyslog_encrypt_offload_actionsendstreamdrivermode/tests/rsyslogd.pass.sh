#!/bin/bash
# packages = rsyslog
source setup.sh

echo "\$ActionSendStreamDriverMode 1" >> $RSYSLOG_D_CONF
