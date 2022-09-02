#!/bin/bash
# packages = audit

echo "-w /sbin/rmmod -p xa -k modules" >> /etc/audit/rules.d/modules.rules
