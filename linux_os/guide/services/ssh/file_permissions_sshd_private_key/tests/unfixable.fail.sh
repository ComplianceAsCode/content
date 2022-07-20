#!/bin/bash

# remediation = none

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chown root:1000 "$FAKE_KEY"
chmod 0777 "$FAKE_KEY"

