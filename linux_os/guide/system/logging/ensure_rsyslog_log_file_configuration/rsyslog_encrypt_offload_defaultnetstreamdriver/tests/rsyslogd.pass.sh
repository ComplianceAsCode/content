#!/bin/bash
# packages = rsyslog
source setup.sh

echo "\$DefaultNetstreamDriver gtls" >> $RSYSLOG_D_CONF
