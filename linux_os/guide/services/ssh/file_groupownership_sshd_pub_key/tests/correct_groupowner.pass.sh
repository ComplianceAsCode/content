#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX.pub)
chgrp root "$FAKE_KEY"
