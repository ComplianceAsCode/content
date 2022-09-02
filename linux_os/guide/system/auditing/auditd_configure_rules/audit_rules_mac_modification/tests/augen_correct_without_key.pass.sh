#!/bin/bash
# packages = audit

echo "-w /etc/selinux/ -p wa" > /etc/audit/rules.d/MAC-policy.rules
