#!/bin/bash
# platform = multi_platform_ubuntu
# packages = rsyslog,sudo-rs

source include.sh
truncate -s 0 /var/log/auth.log
