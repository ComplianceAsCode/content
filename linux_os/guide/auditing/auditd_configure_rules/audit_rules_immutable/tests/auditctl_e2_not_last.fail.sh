#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

# auditctl -R locks the audit system when it reaches "-e 2" and refuses to
# load any rule that follows it, so "-e 2" must be the last directive.
echo "-e 2" > /etc/audit/audit.rules
echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/audit.rules
