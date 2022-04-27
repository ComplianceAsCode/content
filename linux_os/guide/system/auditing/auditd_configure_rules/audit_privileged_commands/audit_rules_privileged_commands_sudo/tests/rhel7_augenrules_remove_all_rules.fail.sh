#!/bin/bash
# packages = audit
# remediation = bash
# platform = Red Hat Enterprise Linux 7,Fedora

mkdir -p /etc/audit/rules.d
rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
