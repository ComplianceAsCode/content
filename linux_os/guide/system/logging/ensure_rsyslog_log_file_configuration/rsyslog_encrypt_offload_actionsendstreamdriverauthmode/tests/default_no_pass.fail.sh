#!/bin/bash
# packages = rsyslog
source setup.sh

if [[ -f $RSYSLOG_D_CONF ]]; then
  sed -i "/^\$ActionSendStreamDriverMod.*/d" /etc/rsyslog.conf
fi
  sed -i "/^\$ActionSendStreamDriverMod.*/d" /etc/rsyslog.conf
