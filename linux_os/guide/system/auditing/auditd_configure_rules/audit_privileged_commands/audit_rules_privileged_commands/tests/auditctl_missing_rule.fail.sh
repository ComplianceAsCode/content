#!/bin/bash
# packages = audit
# remediation = bash
# platform = Oracle Linux 7,Oracle Linux 8,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

./generate_privileged_commands_rule.sh 1000 privileged /etc/audit/audit.rules
sed -i '/newgrp/d' /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
