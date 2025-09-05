#!/bin/bash

export TESTFILLE=/etc/audit/auditd.conf
mkdir -p /etc/audit/
touch $TESTFILLE
chmod 0644 $TESTFILLE
