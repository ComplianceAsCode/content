#!/bin/bash
# packages = aide,crontabs

mkdir -p /etc/cron.daily
echo "/usr/sbin/aide --check" > /etc/cron.daily/aide
