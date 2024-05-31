#!/bin/bash
# packages = audit

# remediation = none

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
true
