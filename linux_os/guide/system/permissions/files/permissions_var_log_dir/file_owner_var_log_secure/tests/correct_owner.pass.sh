#!/bin/bash
# platform = Ubuntu 24.04

id syslog &>/dev/null || useradd syslog
touch /var/log/secure
touch /var/log/secure1.1
touch /var/log/secure.1
touch /var/log/secure-1
chown syslog /var/log/secure*
