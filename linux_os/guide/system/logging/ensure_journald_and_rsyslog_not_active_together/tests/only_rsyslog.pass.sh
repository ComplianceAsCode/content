#!/bin/bash
#
# packages = rsyslog

systemctl start rsyslog
systemctl stop systemd-journald.socket systemd-journald-dev-log.socket 2> /dev/null
systemctl stop systemd-journald 2>/dev/null
