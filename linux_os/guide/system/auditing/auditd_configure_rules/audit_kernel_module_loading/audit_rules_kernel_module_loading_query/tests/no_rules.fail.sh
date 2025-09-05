#!/bin/bash
# remediation = bash
# packages = audit

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
