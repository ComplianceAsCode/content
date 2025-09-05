#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

SSHD_CONFIG="/etc/ssh/sshd_config"

. "$SHARED/utilities.sh"

assert_directive_in_file "$SSHD_CONFIG" ClientAliveInterval "# ClientAliveInterval 10"
assert_directive_in_file "$SSHD_CONFIG" ClientAliveCountMax "ClientAliveCountMax 0"

