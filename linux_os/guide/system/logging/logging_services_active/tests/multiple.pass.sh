#!/bin/bash
#
# packages = rsyslog
# remediation = none

systemctl start rsyslog
systemctl start systemd-journald
