#!/bin/bash
# packages = audit
#

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-w /etc/localtime -p a -k audit_time_rules" >> /etc/audit/rules.d/audit_time_rules.rules
