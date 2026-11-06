#!/bin/bash
# platform = Ubuntu 26.04
# packages = rsyslog,sudo-rs

source include.sh
# Point the route at a path rsyslog cannot open. Deleting a file is not enough:
# omfile has createDirs on by default, so rsyslog recreates both the directory
# and the file as soon as any authpriv event arrives, an ssh login for instance.
# A regular file where the parent directory belongs makes the open fail with
# ENOTDIR for the lifetime of the scenario.
printf '%s\n' 'authpriv.* /var/log/absent-sudo-test-dir/sudo.log' > /etc/rsyslog.d/50-default.conf
rm -rf /var/log/absent-sudo-test-dir
printf '%s\n' 'not a directory' > /var/log/absent-sudo-test-dir
systemctl restart rsyslog.service
