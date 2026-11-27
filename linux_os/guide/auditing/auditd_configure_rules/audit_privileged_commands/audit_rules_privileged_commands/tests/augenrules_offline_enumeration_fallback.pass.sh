#!/bin/bash
# packages = audit
# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 7,Oracle Linux 8

# Create a known setuid file that offline/fallback enumeration would discover.
mkdir -p /usr/local/bin
touch /usr/local/bin/test_priv_cmd
chmod 4755 /usr/local/bin/test_priv_cmd

# Generate rules using the same enumeration logic as remediation.
./generate_privileged_commands_rule.sh {{{ uid_min }}} privileged /etc/audit/rules.d/privileged.rules parity
