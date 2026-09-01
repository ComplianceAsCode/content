#!/bin/bash
#

rpm --setperms cronie crontabs
chmod 0777 /etc/crontab
