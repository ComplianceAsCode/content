#!/bin/bash
# packages = audit
# remediation = bash

echo "-w {{{ faillock_path }}} -p wa -k logins" >> /etc/audit/rules.d/logins.rules
echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/rules.d/logins.rules
echo "-w /var/log/tallylog -p wa -k logins" >> /etc/audit/rules.d/logins.rules
