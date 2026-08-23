#!/bin/bash
# platform = multi_platform_all

mkdir -p /etc/sudoers.d
# Ensure default config is there
if ! grep -q "#includedir /etc/sudoers.d" /etc/sudoers; then
    echo "#includedir /etc/sudoers.d" >> /etc/sudoers
fi

echo "#include /etc/my-sudoers" > /etc/sudoers.d/my-sudoers
