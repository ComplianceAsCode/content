#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-w /sbin/modprobe -p x" >> /etc/audit/audit.rules
