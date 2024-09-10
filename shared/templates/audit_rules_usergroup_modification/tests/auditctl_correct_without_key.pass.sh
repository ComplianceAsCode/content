#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-w {{{ PATH }}} -p wa" >> /etc/audit/audit.rules
