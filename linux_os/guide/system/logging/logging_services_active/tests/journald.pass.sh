#!/bin/bash
#
# packages = rsyslog
# remediation = none

systemctl stop syslog*
systemctl stop rsyslog*
systemctl start systemd-journald
