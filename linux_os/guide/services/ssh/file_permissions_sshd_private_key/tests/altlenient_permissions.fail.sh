#!/bin/bash
#

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chown root:ssh_keys "$FAKE_KEY"
chmod 0777 "$FAKE_KEY"
