#!/bin/bash
#
# packages = rsyslog

# Ensure both services are active
systemctl start rsyslog
systemctl start systemd-journald

# Verify both are running
systemctl is-active rsyslog systemd-journald
