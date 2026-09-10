#!/bin/bash
# platform = multi_platform_ubuntu

machine_id=$(cat /etc/machine-id)

mkdir -p "/var/log/journal/${machine_id}"
install -m 0750 -o root -g systemd-journal /dev/null \
    "/var/log/journal/${machine_id}/leftover.log"
