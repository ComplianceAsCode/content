#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX.pub)
chgrp root "$FAKE_KEY"
