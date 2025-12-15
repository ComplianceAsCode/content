#!/bin/bash
#
# packages = rsyslog

# Stop and mask rsyslog, ensure journald is active
systemctl stop rsyslog
systemctl mask rsyslog
systemctl start systemd-journald

# Verify only journald is running
systemctl is-active systemd-journald
