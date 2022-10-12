#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chown root:ssh_keys "$FAKE_KEY"
chmod 0640 "$FAKE_KEY"
