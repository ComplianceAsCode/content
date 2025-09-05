#!/bin/bash
# packages = audit
# remediation = bash
# platform = Red Hat Enterprise Linux 7,Fedora

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
