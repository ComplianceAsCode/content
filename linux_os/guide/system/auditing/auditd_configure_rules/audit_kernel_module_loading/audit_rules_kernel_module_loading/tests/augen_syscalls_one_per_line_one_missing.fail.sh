#!/bin/bash
# packages = audit

rm -f /etc/audit/rules.d/*

# cut out irrelevant rules for this test
sed -e '7,15d' -e '/.*init.*/d' test_audit.rules > /etc/audit/rules.d/test.rules
