#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux,multi_platform_fedora

# Fedora's sshd-keygen writes the host keys root:root 0600.
FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chgrp root "$FAKE_KEY"
