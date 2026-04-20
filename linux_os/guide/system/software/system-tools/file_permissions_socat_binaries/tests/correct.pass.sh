#!/bin/bash
# platform = multi_platform_all

# Create binary with correct permissions (0000)
touch /usr/bin/socat
chmod 0000 /usr/bin/socat
