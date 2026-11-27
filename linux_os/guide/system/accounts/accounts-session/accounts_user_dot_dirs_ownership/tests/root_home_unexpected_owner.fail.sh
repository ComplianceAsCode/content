#!/bin/bash
# platform = multi_platform_debian
# packages = linux-base

# root has a shell listed in /etc/shells, so its home directory is checked.
mkdir -p /root/.cac-test
chown 2 /root/.cac-test
