#!/bin/bash
# packages = audit
# remediation = bash

rm -f /etc/audit/rules.d/*

# Delete everything that is between "one per line" and "one per arg"
sed '/# one per line/,/# one per arg/d' test_audit.rules > /etc/audit/rules.d/audit.rules
