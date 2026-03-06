#!/bin/bash
#
# packages = rsyslog
# remediation = none

# Stop both logging services
systemctl stop systemd-journald
systemctl stop rsyslog
systemctl mask systemd-journald
systemctl mask rsyslog

# Verify both are stopped
! systemctl is-active rsyslog
! systemctl is-active systemd-journald
