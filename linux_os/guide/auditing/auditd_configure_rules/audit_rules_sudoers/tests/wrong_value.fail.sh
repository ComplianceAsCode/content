#!/bin/bash
# packages = audit

echo "-w /etc/sudo -p wa -k actions" >> /etc/audit/rules.d/actions.rules
