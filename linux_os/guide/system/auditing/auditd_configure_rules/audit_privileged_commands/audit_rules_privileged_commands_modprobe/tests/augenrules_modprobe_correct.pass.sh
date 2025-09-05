#!/bin/bash
# packages = audit

echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/rules.d/modules.rules
