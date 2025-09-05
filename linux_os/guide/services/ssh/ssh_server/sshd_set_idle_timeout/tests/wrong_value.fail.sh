#!/bin/bash

SSHD_CONFIG="/etc/ssh/sshd_config"

. "$SHARED/utilities.sh"

assert_directive_in_file "$SSHD_CONFIG" ClientAliveInterval "ClientAliveInterval 6000"
assert_directive_in_file "$SSHD_CONFIG" ClientAliveCountMax "ClientAliveCountMax 0"
