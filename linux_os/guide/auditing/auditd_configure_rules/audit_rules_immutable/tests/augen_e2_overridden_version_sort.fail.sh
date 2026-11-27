#!/bin/bash
# packages = audit

# augenrules sorts the files with 'ls -v', so 10-other.rules is processed after
# 9-immutable.rules and its "-e 0" wins.
rm -rf /etc/audit/rules.d/*
echo "-e 2" > /etc/audit/rules.d/9-immutable.rules
echo "-e 0" > /etc/audit/rules.d/10-other.rules
