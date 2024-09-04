#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
true
