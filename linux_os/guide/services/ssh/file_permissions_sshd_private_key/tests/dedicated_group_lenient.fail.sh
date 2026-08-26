#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

{{% set dedicated_ssh_groupname = groups.get("dedicated_ssh_keyowner", {"name": "root"}).get("name") %}}

if ! grep -q "{{{ dedicated_ssh_groupname }}}" /etc/group; then
    groupadd "{{{ dedicated_ssh_groupname }}}"
fi

# Keys owned by root:{{{ dedicated_ssh_groupname }}} must still be 0600 or stricter on
# non-immutable systems - the 0640 group-owned exception only applies to rhcos4.
FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chown root:{{{ dedicated_ssh_groupname }}} "$FAKE_KEY"
chmod 0640 "$FAKE_KEY"
