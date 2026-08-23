#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

id syslog &>/dev/null || useradd syslog
touch /var/log/secure
touch /var/log/secure1.1
touch /var/log/secure.1
touch /var/log/secure-1
chown nobody /var/log/secure*
