#!/bin/bash

export TESTFILE=/etc/audit/auditd.conf
mkdir -p /etc/audit/
touch $TESTFILE
chmod 0640 $TESTFILE
