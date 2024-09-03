#!/bin/bash
# packages = audit
# remediation = bash

{{{ setup_auditctl_environment() }}}

rm -f /etc/audit/rules.d/*

# Delete everything that is not between "one per line" and "multiple per arg"
sed '/# one per line/,/# multiple per arg/!d' test_audit.rules > /etc/audit/audit.rules
