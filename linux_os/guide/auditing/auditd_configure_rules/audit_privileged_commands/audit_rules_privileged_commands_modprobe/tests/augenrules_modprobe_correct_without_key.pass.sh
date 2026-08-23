#!/bin/bash
# packages = audit

echo "-w /sbin/modprobe -p x" >> /etc/audit/rules.d/modules.rules
