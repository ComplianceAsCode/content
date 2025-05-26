#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
{{% set dedicated_ssh_groupname = groups.get("dedicated_ssh_keyowner", {}).get("name", "root") %}}

test_group="cac_testgroup"
groupadd $test_group

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chgrp {{{ dedicated_ssh_groupname }}} "$FAKE_KEY"

FAKE_KEY2=$(mktemp -p /etc/ssh/ XXXX_key)
chgrp $test_group "$FAKE_KEY2"
