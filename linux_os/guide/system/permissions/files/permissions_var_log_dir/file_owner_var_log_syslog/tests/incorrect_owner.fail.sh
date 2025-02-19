#!/bin/bash
# packages = rsyslog

if [ ! -f /var/log/syslog ]; then
    mkdir -p /var/log/
    touch /var/log/syslog
fi

useradd testuser_123
chown testuser_123 /var/log/syslog
