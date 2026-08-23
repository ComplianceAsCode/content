#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/audit.rules
