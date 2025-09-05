#!/bin/bash
# packages = audit
# remediation = bash

{{{ setup_auditctl_environment() }}}

rm -f /etc/audit/rules.d/*

# Deletes everything up do "one per line"
# Then deletes everything from "one per arg" until end of file
sed '/# one per line/,/# multiple per arg/d;/# one per arg/,$d' test_audit.rules > /etc/audit/audit.rules
