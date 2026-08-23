#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "-e 2" > /etc/audit/audit.rules
