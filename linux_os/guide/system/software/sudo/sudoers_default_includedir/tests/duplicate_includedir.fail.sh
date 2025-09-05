#!/bin/bash
# platform = multi_platform_all

# duplicate default entry
if grep -q "#includedir /etc/sudoers.d" /etc/sudoers; then
    echo "#includedir /etc/sudoers.d" >> /etc/sudoers
fi
