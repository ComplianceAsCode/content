#!/bin/bash
# platform = multi_platform_ubuntu

mkdir -p /run/log/journal /var/log/journal
# Create dummy journal files so the recursive file ownership check has
# something to scan, and make everything owned by root.
touch /var/log/journal/system.journal
touch /run/log/journal/system.journal
chown -R root /run/log/journal /var/log/journal
