#!/bin/bash
# packages = audit

echo "-w /usr/share/selinux/ -p wa" > /etc/audit/rules.d/MAC-policy.rules
