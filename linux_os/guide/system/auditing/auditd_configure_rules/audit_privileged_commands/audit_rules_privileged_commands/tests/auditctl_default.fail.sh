#!/bin/bash
# packages = audit
# remediation = bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
