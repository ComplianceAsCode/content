#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "-w /etc/passwd -p w -k MAC-policy" > /etc/audit/audit.rules

