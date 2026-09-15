#!/bin/bash
# platform = multi_platform_debian,multi_platform_ubuntu

# Ensure there is no dedicated syslog user, as on systems using syslog-ng
# instead of rsyslog.
userdel -r syslog 2>/dev/null || true

useradd -m -s /bin/bash test_user_with_shell

chown root:root -R /var/log/*

touch /var/log/test_log_file
chown test_user_with_shell /var/log/test_log_file
