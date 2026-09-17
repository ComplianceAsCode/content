#!/bin/bash
# platform = Ubuntu 26.04
# packages = rsyslog,sudo-rs

source include.sh
systemctl disable --now rsyslog.service
systemctl mask rsyslog.service
sed -i 's/ForwardToSyslog=yes/ForwardToSyslog=no/' /etc/systemd/journald.conf.d/zz-sudo-test.conf
systemctl restart systemd-journald.service
logger -p authpriv.notice -t sudo 'Recent event in volatile storage only'
journalctl --sync
