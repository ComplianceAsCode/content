#!/bin/bash
# platform = multi_platform_ubuntu
# packages = rsyslog,sudo-rs

source include.sh
systemctl disable --now rsyslog.service
systemctl mask rsyslog.service
printf '%s\n' 'sudo[1234]: old event from a previous logging configuration' > /var/log/auth.log
