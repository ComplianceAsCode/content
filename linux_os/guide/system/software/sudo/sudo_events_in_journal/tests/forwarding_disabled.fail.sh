#!/bin/bash
# platform = multi_platform_ubuntu
# packages = rsyslog,sudo-rs

source include.sh
sed -i 's/ForwardToSyslog=yes/ForwardToSyslog=no/' /etc/systemd/journald.conf.d/zz-sudo-test.conf
systemctl restart systemd-journald.service
