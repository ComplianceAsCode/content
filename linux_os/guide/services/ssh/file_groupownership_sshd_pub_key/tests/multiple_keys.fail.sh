#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

test_group="cac_testgroup"
groupadd $test_group

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX.pub)
chgrp ssh_keys "$FAKE_KEY"

FAKE_KEY2=$(mktemp -p /etc/ssh/ XXXX.pub)
chgrp $test_group "$FAKE_KEY2"
