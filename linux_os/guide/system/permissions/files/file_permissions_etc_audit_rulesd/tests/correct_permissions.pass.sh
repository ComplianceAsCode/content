#!/bin/bash

export TESTFILE=/etc/audit/rules.d/test_rule.rules
mkdir -p /etc/audit/rules.d/
touch $TESTFILE
chmod 0640 $TESTFILE
