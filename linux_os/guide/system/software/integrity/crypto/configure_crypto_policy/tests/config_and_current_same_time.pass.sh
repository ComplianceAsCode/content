#!/bin/bash
# platform = Red Hat Enterprise Linux 8

# IMPORTANT: This is a false negative scenario.
# File /etc/crypto-policies/config can be newer than /etc/crypto-policies/state/current
# but the difference can be in milliseconds and after rounding to seconds timestamps of
# those files can be same, thus incompliant.
# With a precision of seconds in OVAL, there is not really much we can do to detect this.
update-crypto-policies --set "DEFAULT"
touch -r /etc/crypto-policies/state/current /etc/crypto-policies/config
