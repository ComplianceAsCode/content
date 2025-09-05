#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel

test_group="cac_testgroup"
groupadd $test_group

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chgrp $test_group "$FAKE_KEY"
