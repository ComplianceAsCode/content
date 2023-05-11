#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel

test_user="cac_testuser"
useradd $test_user

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX.pub)
chown root "$FAKE_KEY"

FAKE_KEY2=$(mktemp -p /etc/ssh/ XXXX.pub)
chown $test_user "$FAKE_KEY2"
