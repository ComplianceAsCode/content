#!/bin/bash
# packages = audit

echo "-w /sbin/insmod -p xa" >> /etc/audit/rules.d/modules.rules
