#!/bin/bash
# packages = audit

# augenrules keeps only the last -e directive it finds in /etc/audit/rules.d/*.rules
# (version sort order), so the "-e 1" in 30-other.rules overrides the "-e 2".
rm -rf /etc/audit/rules.d/*
echo "-e 2" > /etc/audit/rules.d/10-immutable.rules
echo "-w /etc/passwd -p wa -k identity" > /etc/audit/rules.d/30-other.rules
echo "-e 1" >> /etc/audit/rules.d/30-other.rules
