#!/bin/bash

export TESTFILLE=/etc/audit/rules.d/test_rule.rules
mkdir -p /etc/audit/rules.d/
touch $TESTFILLE
chmod 0644 $TESTFILLE
