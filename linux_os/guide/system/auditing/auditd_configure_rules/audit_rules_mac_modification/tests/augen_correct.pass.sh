#!/bin/bash
# packages = audit

echo "-w /etc/selinux/ -p wa -k MAC-policy" > /etc/audit/rules.d/MAC-policy.rules
