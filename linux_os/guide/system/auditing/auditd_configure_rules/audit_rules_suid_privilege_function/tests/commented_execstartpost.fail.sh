#!/bin/bash
# packages = audit

if [[ $(grep '^ExecStartPost' /usr/lib/systemd/system/auditd.service) ]]; then
    sed -i 's/ExecStartPost=/#ExecStartPost=/g' /usr/lib/systemd/system/auditd.service
fi

rm -rf /etc/audit/audit.rules
rm -rf /etc/audit/rules.d/privileged.rules
