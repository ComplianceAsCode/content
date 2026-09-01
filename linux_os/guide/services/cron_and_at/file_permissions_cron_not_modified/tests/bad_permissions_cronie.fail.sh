#!/bin/bash
#

rpm --setperms cronie crontabs
chmod 0644 /etc/cron.d
