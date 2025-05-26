#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
{{% set dedicated_ssh_groupname = groups.get("dedicated_ssh_keyowner", {}).get("name", "root") %}}

if ! grep -q "{{{ dedicated_ssh_groupname }}}" /etc/group; then
    groupadd "{{{ dedicated_ssh_groupname }}}"
fi

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chgrp  "{{{ dedicated_ssh_groupname }}}" "$FAKE_KEY"
