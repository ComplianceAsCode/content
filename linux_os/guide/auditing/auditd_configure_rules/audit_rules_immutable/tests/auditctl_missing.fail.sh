#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "some value" > /etc/audit/audit.rules
