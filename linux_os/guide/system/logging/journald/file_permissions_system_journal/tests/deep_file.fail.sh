#!/bin/bash
# platform = multi_platform_ubuntu

machine_id=$(cat /etc/machine-id)
deep_dir="/var/log/journal/${machine_id}/nested/deeper"

mkdir -p "$deep_dir"
chown root:systemd-journal "$deep_dir" "/var/log/journal/${machine_id}/nested"
chmod 2750 "$deep_dir" "/var/log/journal/${machine_id}/nested"

install -m 0750 -o root -g systemd-journal /dev/null \
    "${deep_dir}/system@deadbeef.journal"
