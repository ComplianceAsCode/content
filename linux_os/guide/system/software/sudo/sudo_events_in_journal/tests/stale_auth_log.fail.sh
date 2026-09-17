#!/bin/bash
# platform = Ubuntu 26.04
# packages = rsyslog,sudo-rs

source include.sh
systemctl disable --now rsyslog.service
systemctl mask rsyslog.service
printf '%s\n' 'sudo[1234]: old event from a previous logging configuration' > /var/log/auth.log
