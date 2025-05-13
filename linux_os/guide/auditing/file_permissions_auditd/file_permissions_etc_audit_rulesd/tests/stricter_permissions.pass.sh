#!/bin/bash
#

rm -rf /etc/audit/rules.d/
mkdir -p /etc/audit/rules.d/
export TESTFILE=/etc/audit/rules.d/test_rule.rules
mkdir -p $(dirname $TESTFILE)
touch $TESTFILE
chmod 0600 $TESTFILE
