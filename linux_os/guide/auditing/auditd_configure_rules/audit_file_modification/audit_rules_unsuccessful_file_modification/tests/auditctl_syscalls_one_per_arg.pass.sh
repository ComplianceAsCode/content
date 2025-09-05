#!/bin/bash
# packages = audit
# remediation = bash

{{{ setup_auditctl_environment() }}}

rm -f /etc/audit/rules.d/*

# Delete everything that is between "one per line" and "one per arg"
sed '/# one per line/,/# one per arg/d' test_audit.rules > /etc/audit/audit.rules
