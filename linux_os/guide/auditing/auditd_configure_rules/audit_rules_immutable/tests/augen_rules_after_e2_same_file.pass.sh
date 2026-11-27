#!/bin/bash
# packages = audit

# augenrules moves the last -e directive to the end of the generated
# audit.rules, so rules after "-e 2" in the same file are still loaded.
rm -rf /etc/audit/rules.d/*
echo "-e 2" > /etc/audit/rules.d/immutable.rules
echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/rules.d/immutable.rules
