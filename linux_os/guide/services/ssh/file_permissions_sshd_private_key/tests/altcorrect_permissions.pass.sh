#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

{{% set dedicated_ssh_groupname = groups.get("dedicated_ssh_keyowner", {"name": "root"}).get("name") %}}

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chown root:{{{ dedicated_ssh_groupname }}} "$FAKE_KEY"

{{%- if dedicated_ssh_groupname == 'root' %}}
chmod 0600 "$FAKE_KEY"
{{%- else %}}
chmod 0640 "$FAKE_KEY"
{{%- endif %}}
