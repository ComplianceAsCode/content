#!/bin/bash
# packages = audit

# Rules in a file that sorts after the one carrying "-e 2" are fine with
# augenrules as long as they do not carry another -e directive.
rm -rf /etc/audit/rules.d/*
echo "-e 2" > /etc/audit/rules.d/10-immutable.rules
echo "-w /etc/passwd -p wa -k identity" > /etc/audit/rules.d/30-other.rules
