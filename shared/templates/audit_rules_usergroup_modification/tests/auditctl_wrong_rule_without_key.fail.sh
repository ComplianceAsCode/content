#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-w {{{ PATH }}} -p w" >> /etc/audit/audit.rules
