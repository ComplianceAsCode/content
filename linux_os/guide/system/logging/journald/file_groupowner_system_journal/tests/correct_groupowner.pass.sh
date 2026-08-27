#!/bin/bash
# platform = multi_platform_ubuntu

getent group "systemd-journal" &>/dev/null || groupadd systemd-journal

mkdir -p /run/log/journal /var/log/journal
touch /var/log/journal/system.journal
touch /run/log/journal/system.journal
chgrp -R systemd-journal /run/log/journal /var/log/journal
