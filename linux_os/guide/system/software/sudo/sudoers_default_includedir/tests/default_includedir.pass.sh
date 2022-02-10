#!/bin/bash
# platform = multi_platform_all

# Ensure default config is there
if ! grep -q "#includedir /etc/sudoers.d" /etc/sudoers; then
    echo "#includedir /etc/sudoers.d" >> /etc/sudoers
fi
