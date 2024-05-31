#!/bin/bash
# packages = audit
echo "-w /etc/sudoers -p wa" >> /etc/audit/rules.d/actions.rules
