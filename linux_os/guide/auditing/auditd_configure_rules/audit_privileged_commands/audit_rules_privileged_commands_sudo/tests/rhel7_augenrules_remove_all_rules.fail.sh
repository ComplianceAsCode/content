#!/bin/bash
# packages = audit
# remediation = bash
# platform = Fedora,Oracle Linux 7,Red Hat Enterprise Linux 7

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
