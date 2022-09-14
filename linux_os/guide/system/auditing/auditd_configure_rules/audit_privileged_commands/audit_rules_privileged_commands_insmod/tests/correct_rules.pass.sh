#!/bin/bash
# packages = audit

echo "-w /sbin/insmod -p x -k modules" >> /etc/audit/rules.d/modules.rules
