#!/bin/bash
# packages = rsyslog
source setup.sh

echo "\$DefaultNetstreamDriver none" >> $RSYSLOG_CONF
