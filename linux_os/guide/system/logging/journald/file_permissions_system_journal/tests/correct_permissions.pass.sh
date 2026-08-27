#!/bin/bash
# platform = multi_platform_ubuntu

mkdir -p /run/log/journal /var/log/journal
find /run/log/journal /var/log/journal -type f -exec chmod 0640 {} \;

machine_id="$(cat /etc/machine-id)"
mkdir -p "/var/log/journal/${machine_id}"
touch "/var/log/journal/${machine_id}/system.journal"
chmod 0640 "/var/log/journal/${machine_id}/system.journal"
