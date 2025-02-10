#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

id -u syslog || useradd -r -s /bin/false syslog || true
touch /var/log/test.log
chown syslog /var/log/test.log
