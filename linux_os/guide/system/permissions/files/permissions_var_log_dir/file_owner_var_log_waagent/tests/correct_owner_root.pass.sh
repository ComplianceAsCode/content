#!/bin/bash
# platform = Ubuntu 24.04

id syslog &>/dev/null || useradd syslog
touch /var/log/waagent.log
touch /var/log/waagent.log1
chown root /var/log/waagent.log*
