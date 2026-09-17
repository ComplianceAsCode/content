#!/bin/bash
# platform = Ubuntu 26.04
# packages = rsyslog,sudo-rs

source include.sh
truncate -s 0 /var/log/auth.log
