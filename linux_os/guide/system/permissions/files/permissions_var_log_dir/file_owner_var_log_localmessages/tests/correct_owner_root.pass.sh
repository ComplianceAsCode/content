#!/bin/bash
# platform = Ubuntu 24.04

id syslog &>/dev/null || useradd syslog
touch /var/log/localmessages
touch /var/log/localmessages1
chown root /var/log/localmessages*
