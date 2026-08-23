#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

{{% set dedicated_ssh_groupname = groups.get("dedicated_ssh_keyowner", {"name": "root"}).get("name") %}}

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chown root:{{{ dedicated_ssh_groupname }}} "$FAKE_KEY"
chmod 0777 "$FAKE_KEY"
