#!/bin/bash
# remediation = bash

echo "-w /var/log/tallylog -p wa -k logins" >> /etc/audit/rules.d/logins.rules
echo "-w /var/run/faillock -p wa -k logins" >> /etc/audit/rules.d/logins.rules
echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/rules.d/logins.rules
