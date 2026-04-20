#!/bin/bash
# platform = multi_platform_all

# Create binary with wrong permissions (0755)
touch /usr/bin/socat
chmod 0755 /usr/bin/socat
