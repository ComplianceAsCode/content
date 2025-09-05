#!/bin/bash
#

export TESTFILE=/etc/audit/rules.d/test_rule.rules
mkdir -p $(dirname $TESTFILE)
touch $TESTFILE
chmod 0600 $TESTFILE
