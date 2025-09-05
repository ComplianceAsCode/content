#!/bin/bash
# packages = audit
echo "-w /etc/sudoers.d/ -p wa" >> /etc/audit/rules.d/actions.rules
