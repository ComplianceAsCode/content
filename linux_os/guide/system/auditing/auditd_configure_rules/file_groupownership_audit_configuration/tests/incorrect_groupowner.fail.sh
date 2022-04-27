#!/bin/bash
# packages = audit

groupadd group_test
export TESTFILLE=/etc/audit/rules.d/test_rule.rules
export AUDITFILE=/etc/audit/auditd.conf
touch $TESTFILLE
touch $AUDITFILE
chgrp group_test $TESTFILLE
chgrp group_test $AUDITFILE
