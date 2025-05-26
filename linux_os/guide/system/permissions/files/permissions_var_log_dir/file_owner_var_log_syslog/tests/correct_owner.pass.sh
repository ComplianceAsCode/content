#!/bin/bash
# platform = multi_platform_ubuntu


id syslog &>/dev/null || useradd syslog
if [ ! -f /var/log/syslog ]; then
    mkdir -p /var/log/
    touch /var/log/syslog
fi

chown syslog /var/log/syslog

