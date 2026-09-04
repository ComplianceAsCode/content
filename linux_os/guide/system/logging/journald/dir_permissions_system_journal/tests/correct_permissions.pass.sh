#!/bin/bash
# platform = multi_platform_ubuntu

mkdir -p /run/log/journal /var/log/journal
find /run/log/journal /var/log/journal -type d -exec chmod 2750 {} \;
