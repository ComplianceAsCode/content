#!/bin/bash
# platform = Ubuntu 24.04

id syslog &>/dev/null || useradd syslog
touch /var/log/cloud-init.log
touch /var/log/cloud-init.log1
chown syslog /var/log/cloud-init.log*
