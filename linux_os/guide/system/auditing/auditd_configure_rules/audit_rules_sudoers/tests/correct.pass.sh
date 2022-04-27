#!/bin/bash
# packages = audit
mkdir -p /etc/audit/rules.d/
echo "-w /etc/sudoers -p wa -k actions" >> /etc/audit/rules.d/actions.rules
