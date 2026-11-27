#!/bin/bash
# platform = multi_platform_ubuntu

machine_id="$(cat /etc/machine-id)"

mkdir -p "/run/log/journal/${machine_id}/nested/deeper"
mkdir -p "/var/log/journal/${machine_id}/nested/deeper"

chmod 2755 "/run/log/journal/${machine_id}/nested"
chmod 2777 "/run/log/journal/${machine_id}/nested/deeper"
chmod 2755 "/var/log/journal/${machine_id}/nested"
chmod 2777 "/var/log/journal/${machine_id}/nested/deeper"
