#!/bin/bash
# packages = audit

echo "-w /usr/share/selinux/ -p wa -k MAC-policy" > /etc/audit/rules.d/MAC-policy.rules
