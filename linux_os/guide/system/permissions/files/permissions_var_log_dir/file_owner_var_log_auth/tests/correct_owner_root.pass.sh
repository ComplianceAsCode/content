#!/bin/bash
# platform = Ubuntu 24.04

id syslog &>/dev/null || useradd syslog
touch /var/log/auth.log
chown root /var/log/auth.log
