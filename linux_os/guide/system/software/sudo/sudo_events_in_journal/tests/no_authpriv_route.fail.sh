#!/bin/bash
# platform = Ubuntu 26.04
# packages = rsyslog,sudo-rs

source include.sh
printf '%s\n' 'daemon.* /var/log/daemon.log' > /etc/rsyslog.d/50-default.conf
systemctl restart rsyslog.service
printf '%s\n' 'sudo[1234]: old event from a removed route' > /var/log/auth.log
