#!/bin/bash

export TESTFILE=/etc/audit/rules.d/test_rule.rules
export AUDITFILE=/etc/audit/auditd.conf
mkdir -p /etc/audit/rules.d/
touch $TESTFILE
touch $AUDITFILE
chgrp root $TESTFILE
chgrp root $AUDITFILE
