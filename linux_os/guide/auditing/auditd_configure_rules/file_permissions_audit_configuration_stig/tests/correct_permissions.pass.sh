#!/bin/bash
# packages = audit

rm -rf /etc/audit/*
mkdir -p /etc/audit/rules.d/
export TESTFILE=/etc/audit/rules.d/test_rule.rules
export AUDITFILE=/etc/audit/auditd.conf
# Create a dummy rule file to trigger a rewrite of audit.rules.
echo '-a always,exit -F arch=b64 -S getuid -k test_execstartpost_2' > "$TESTFILE"

augenrules --load # augenrules --load hardcodes chmod 0640 on audit.rules on every rewrite of the rules.d files.
# we override this with a systemd dropin that runs chmod 0600 after augenrules finishes.

chmod 0600 "$TESTFILE"
chmod 0600 "$AUDITFILE"
