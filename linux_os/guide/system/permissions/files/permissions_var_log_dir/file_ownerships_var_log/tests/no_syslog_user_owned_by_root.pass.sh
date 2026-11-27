#!/bin/bash
# platform = multi_platform_debian,multi_platform_ubuntu

# Ensure there is no dedicated syslog user, as on systems using syslog-ng
# instead of rsyslog.
userdel -r syslog 2>/dev/null || true

chown root -R /var/log/*

touch /var/log/test.log
chown root /var/log/test.log
