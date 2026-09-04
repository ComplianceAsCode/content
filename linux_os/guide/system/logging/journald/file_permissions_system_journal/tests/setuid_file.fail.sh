#!/bin/bash
# platform = multi_platform_ubuntu

machine_id="$(cat /etc/machine-id)"
mkdir -p "/run/log/journal/${machine_id}" "/var/log/journal/${machine_id}"

touch "/run/log/journal/${machine_id}/user-1000.journal"
touch "/var/log/journal/${machine_id}/user-1000.journal"
chmod 4640 "/run/log/journal/${machine_id}/user-1000.journal"
chmod 4640 "/var/log/journal/${machine_id}/user-1000.journal"
