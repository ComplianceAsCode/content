#!/bin/bash
# packages = audit

echo "-w /sbin/rmmod -p x" >> /etc/audit/rules.d/modules.rules
