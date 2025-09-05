#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel

if ! grep -q ssh_keys /etc/group; then
    groupadd ssh_keys
fi

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chgrp ssh_keys "$FAKE_KEY"
