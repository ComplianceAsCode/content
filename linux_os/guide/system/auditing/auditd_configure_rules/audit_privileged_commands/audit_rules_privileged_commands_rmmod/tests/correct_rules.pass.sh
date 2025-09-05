#!/bin/bash
# packages = audit

echo "-w /sbin/rmmod -p x -k modules" >> /etc/audit/rules.d/modules.rules
