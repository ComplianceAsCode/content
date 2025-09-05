#!/bin/bash

groupadd group_test
export TESTFILLE=/etc/audit/rules.d/test_rule.rules
export AUDITFILE=/etc/audit/auditd.conf
mkdir -p /etc/audit/rules.d/
touch $TESTFILLE
touch $AUDITFILE
chgrp group_test $TESTFILLE
chgrp group_test $AUDITFILE
