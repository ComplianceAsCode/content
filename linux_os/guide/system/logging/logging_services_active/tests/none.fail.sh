#!/bin/bash
#
# packages = rsyslog
# remediation = none

systemctl stop systemd-journald*
systemctl stop syslog*
systemctl stop rsyslog*
