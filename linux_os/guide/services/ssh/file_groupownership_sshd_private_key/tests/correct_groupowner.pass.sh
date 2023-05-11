#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chgrp ssh_keys "$FAKE_KEY"
