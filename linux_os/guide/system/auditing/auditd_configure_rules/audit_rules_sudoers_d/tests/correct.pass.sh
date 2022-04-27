#!/bin/bash
# packages = audit
mkdir -p /etc/audit/rules.d/
echo "-w /etc/sudoers.d/ -p wa -k actions" >> /etc/audit/rules.d/actions.rules
