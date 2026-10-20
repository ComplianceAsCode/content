#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

# Comments and blank lines after "-e 2" are not directives.
echo "-w /etc/passwd -p wa -k identity" > /etc/audit/audit.rules
echo "-e 2" >> /etc/audit/audit.rules
echo "# trailing comment" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules
