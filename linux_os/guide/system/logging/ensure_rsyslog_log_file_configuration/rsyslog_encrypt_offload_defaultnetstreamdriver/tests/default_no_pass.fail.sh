#!/bin/bash
# packages = rsyslog
source setup.sh

if [[ -f RSYSLOG_D_CONF ]]; then
  sed -i i/\$DefaultNetstreamDriver*.$//g $RSYSLOG_D_CONF
fi
  sed -i i/\$DefaultNetstreamDriver*.$//g $RSYSLOG_CONF
