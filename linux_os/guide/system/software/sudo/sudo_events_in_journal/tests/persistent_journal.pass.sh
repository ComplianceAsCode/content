#!/bin/bash
# platform = Ubuntu 26.04
# packages = rsyslog,sudo-rs

source include.sh
systemctl disable --now rsyslog.service
systemctl mask rsyslog.service
sed -i 's/Storage=volatile/Storage=persistent/;s/ForwardToSyslog=yes/ForwardToSyslog=no/' \
    /etc/systemd/journald.conf.d/zz-sudo-test.conf
mkdir -p /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal
systemctl restart systemd-journald.service
journalctl --flush
