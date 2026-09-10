#!/bin/bash
# platform = multi_platform_ubuntu

machine_id="$(cat /etc/machine-id)"
mkdir -p "/run/log/journal/${machine_id}" "/var/log/journal/${machine_id}"

touch "/run/log/journal/${machine_id}/user-1000.journal"
touch "/var/log/journal/${machine_id}/user-1000.journal"
chmod 0644 "/run/log/journal/${machine_id}/user-1000.journal"
chmod 0644 "/var/log/journal/${machine_id}/user-1000.journal"
