#!/bin/bash
# packages = audit

echo "-w /sbin/rmmod -p a -k modules" >> /etc/audit/rules.d/modules.rules
