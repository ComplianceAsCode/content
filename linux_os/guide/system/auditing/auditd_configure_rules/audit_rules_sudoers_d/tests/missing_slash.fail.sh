#!/bin/bash
# packages = audit

echo "-w /etc/sudoers.d -p wa -k actions" >> /etc/audit/rules.d/actions.rules
