#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

{{% set dedicated_ssh_groupname = groups.get("dedicated_ssh_keyowner", {"name": "root"}).get("name") %}}

if ! grep -q "{{{ dedicated_ssh_groupname }}}" /etc/group; then
    groupadd "{{{ dedicated_ssh_groupname }}}"
fi

# The default host keys ship as root:{{{ dedicated_ssh_groupname }}} with mode 0640 on RHEL,
# which is now a finding on non-immutable systems - harden them so the whole
# system is compliant for this pass scenario.
chmod 0600 /etc/ssh/*_key

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chown root:{{{ dedicated_ssh_groupname }}} "$FAKE_KEY"
chmod 0600 "$FAKE_KEY"
