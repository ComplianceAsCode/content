#!/bin/bash
# platform = multi_platform_ubuntu

getent group "systemd-journal" &>/dev/null || groupadd systemd-journal

machine_id="$(cat /etc/machine-id)"
mkdir -p "/run/log/journal/${machine_id}/nested/deeper"
mkdir -p "/var/log/journal/${machine_id}/nested/deeper"

chgrp nogroup "/run/log/journal/${machine_id}/nested/deeper"
chgrp nogroup "/var/log/journal/${machine_id}/nested/deeper"
