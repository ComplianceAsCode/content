#!/bin/bash
# packages = rsyslog
source setup.sh

if [[ -f $RSYSLOG_D_CONF ]]; then
  sed -i "/^\$ActionSendStreamDriverMod.*/d" $RSYSLOG_D_CONF
fi
  sed -i "/^\$ActionSendStreamDriverMod.*/d" $RSYSLOG_CONF
