#!/bin/bash
# platform = multi_platform_ubuntu

machine_id=$(cat /etc/machine-id)
namespace_dir="/var/log/journal/${machine_id}.testnamespace"

mkdir -p "$namespace_dir"
chown root:systemd-journal "$namespace_dir"
chmod 2750 "$namespace_dir"

install -m 0750 -o root -g systemd-journal /dev/null \
    "${namespace_dir}/system.journal"
