#!/bin/bash

rm -rf /etc/rsyslog.d
sed -i '/^[[:space:]]*cron\.\*/d' /etc/rsyslog.conf
