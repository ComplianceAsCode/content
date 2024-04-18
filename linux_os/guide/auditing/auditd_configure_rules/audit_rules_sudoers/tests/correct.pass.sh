#!/bin/bash
# packages = audit
echo "-w /etc/sudoers -p wa -k actions" >> /etc/audit/rules.d/actions.rules
