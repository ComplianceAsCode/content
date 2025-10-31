#!/bin/bash
# packages = rsyslog
. remove_cron_logging.sh

touch /etc/rsyslog.conf

remove_cron_logging

rm -rf /etc/rsyslog.d
