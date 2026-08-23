#!/bin/bash
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# packages = crypto-policies-scripts

# IMPORTANT: This is a false negative scenario.
# File /etc/crypto-policies/config can be newer than /etc/crypto-policies/state/current,
# which should always be a finding.
# But the difference can be in a couple of milliseconds, and timestamps of
# those files rounded to seconds can be same, thus making the OVAL test pass, although the system is incompliant.
# The scenario equalizes those timestamps, so the corresponding test always passes.
# With a precision of seconds in OVAL, there is not really much we can do to detect this.
update-crypto-policies --set "DEFAULT"
touch -r /etc/crypto-policies/state/current /etc/crypto-policies/config
