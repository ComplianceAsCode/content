#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

touch /var/log/waagent.log
touch /var/log/waagent.log1
chown syslog /var/log/waagent.log*
