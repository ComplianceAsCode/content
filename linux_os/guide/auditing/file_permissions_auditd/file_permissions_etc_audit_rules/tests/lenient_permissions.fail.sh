#!/bin/bash
# packages = audit

export TESTFILE=/etc/audit/audit.rules
mkdir -p $(dirname $TESTFILE)
touch $TESTFILE
chmod 0777 $TESTFILE
