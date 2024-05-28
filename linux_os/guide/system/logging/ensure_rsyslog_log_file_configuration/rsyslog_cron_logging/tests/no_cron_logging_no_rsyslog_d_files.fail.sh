#!/bin/bash

rm -rf /etc/rsyslog.d
touch /etc/rsyslog.conf
sed -i '/^[[:space:]]*cron\.\*/d' /etc/rsyslog.conf
