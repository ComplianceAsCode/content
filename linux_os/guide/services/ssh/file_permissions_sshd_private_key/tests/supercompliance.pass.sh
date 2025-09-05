#!/bin/bash

# platforms = multi_platform_rhel

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chown root:ssh_keys "$FAKE_KEY"
chmod 0400 "$FAKE_KEY"

FAKE_KEY_ROOT=$(mktemp -p /etc/ssh/ XXXX_key)
chown root:root "$FAKE_KEY_ROOT"
chmod 0400 "$FAKE_KEY_ROOT"

