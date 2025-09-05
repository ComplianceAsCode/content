#!/bin/bash
# remediation = none

# The rule doesn't remediate the ClientAliveCountMax setting, we have another rule for that.

SSHD_CONFIG="/etc/ssh/sshd_config"

. "$SHARED/utilities.sh"

assert_directive_in_file "$SSHD_CONFIG" ClientAliveInterval "ClientAliveInterval 10"
assert_directive_in_file "$SSHD_CONFIG" ClientAliveCountMax "# ClientAliveCountMax 0"
