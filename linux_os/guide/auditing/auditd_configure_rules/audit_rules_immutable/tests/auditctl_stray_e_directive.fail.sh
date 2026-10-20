#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "-e 1" > /etc/audit/audit.rules
echo "-e 2" >> /etc/audit/audit.rules
