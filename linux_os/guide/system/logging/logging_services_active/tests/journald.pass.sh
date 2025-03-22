#!/bin/bash
#
# packages = rsyslog

systemctl stop syslog*
systemctl stop rsyslog*
systemctl start systemd-journald
