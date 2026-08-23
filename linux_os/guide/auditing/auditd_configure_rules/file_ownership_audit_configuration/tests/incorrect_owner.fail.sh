#!/bin/bash
# packages = audit

useradd testuser_123
chown testuser_123 /etc/audit/audit.rules
chown testuser_123 /etc/audit/auditd.conf
chown testuser_123 -R /etc/audit/rules.d/
