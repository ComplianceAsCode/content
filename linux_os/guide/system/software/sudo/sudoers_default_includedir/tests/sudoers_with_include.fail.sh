#!/bin/bash
# platform = multi_platform_all

# Ensure default config is there
if ! grep -q "#includedir /etc/sudoers.d" /etc/sudoers; then
    echo "#includedir /etc/sudoers.d" >> /etc/sudoers
fi

if ! grep -q "#include " /etc/sudoers; then
    echo "#include /etc/my-sudoers" >> /etc/sudoers
fi
