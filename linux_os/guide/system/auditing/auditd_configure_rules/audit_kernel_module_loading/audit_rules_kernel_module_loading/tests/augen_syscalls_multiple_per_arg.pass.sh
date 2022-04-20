#!/bin/bash


rm -f /etc/audit/rules.d/*

# cut out irrelevant rules for this test
sed '1,8d' test_audit.rules > /etc/audit/rules.d/test.rules
sed -i '4,7d' /etc/audit/rules.d/test.rules
