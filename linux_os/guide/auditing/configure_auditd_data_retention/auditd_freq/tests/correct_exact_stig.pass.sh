#!/bin/bash
# packages = audit
# variables = var_auditd_freq=100
# This TS is a regression test for https://issues.redhat.com/browse/RHEL-64013
echo "freq = 100" > "/etc/audit/auditd.conf"
