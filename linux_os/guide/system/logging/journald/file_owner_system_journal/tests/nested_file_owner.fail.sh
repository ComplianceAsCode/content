#!/bin/bash
# platform = multi_platform_ubuntu

id testuser_123 &>/dev/null || useradd testuser_123

machine_id="$(cat /etc/machine-id)"
mkdir -p "/run/log/journal/${machine_id}/nested/deeper"
mkdir -p "/var/log/journal/${machine_id}/nested/deeper"

touch "/run/log/journal/${machine_id}/nested/deeper/user-1000.journal"
touch "/var/log/journal/${machine_id}/nested/deeper/user-1000.journal"
chown testuser_123 "/run/log/journal/${machine_id}/nested/deeper/user-1000.journal"
chown testuser_123 "/var/log/journal/${machine_id}/nested/deeper/user-1000.journal"
