#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "-e 1" > /etc/audit/audit.rules

