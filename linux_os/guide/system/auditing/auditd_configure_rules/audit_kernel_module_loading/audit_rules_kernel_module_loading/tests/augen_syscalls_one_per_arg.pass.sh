#!/bin/bash


rm -f /etc/audit/rules.d/*

# cut out irrelevant rules for this test
sed '1,13d' test_audit.rules > /etc/audit/rules.d/test.rules
