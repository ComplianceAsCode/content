#!/bin/bash
# packages = audit
# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 7,Oracle Linux 8

./generate_privileged_commands_rule.sh {{{ uid_min }}} privileged /etc/audit/audit.rules
sed -i -E 's/^(.*path=[[:graph:]]+) -F perm=x(.*$)/\1\2/' /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
