#!/bin/bash
# platform = Red Hat Enterprise Linux 8

# IMPORTANT: This is a false negative scenario.
# File /etc/crypto-policies/config is newer than /etc/crypto-policies/state/current, thus incompliant,
# but the OVAL evaluation restuls in pass.
# With a precision of seconds in OVAL, there is not really much we can do to detect this.
update-crypto-policies --set "DEFAULT"
touch /etc/crypto-policies/config
