#!/bin/bash
# packages = audit

chown 0 /etc/audit/audit.rules
chown 0 /etc/audit/auditd.conf
chown 0 -R /etc/audit/rules.d/
