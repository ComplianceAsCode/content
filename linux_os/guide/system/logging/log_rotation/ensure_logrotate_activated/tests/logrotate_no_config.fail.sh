#!/bin/bash

sed -i "/^daily/d" /etc/logrotate.conf
rm /etc/cron.daily/logrotate
