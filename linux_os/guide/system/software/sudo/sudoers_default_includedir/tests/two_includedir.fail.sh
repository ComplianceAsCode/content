#!/bin/bash
# platform = multi_platform_all

# Ensure that there are two different indludedirs
if ! grep -q "#includedir /etc/sudoers.d" /etc/sudoers; then
    echo "#includedir /etc/sudoers.d" >> /etc/sudoers
fi
echo "#includedir /opt/extra_config.d" >> /etc/sudoers
