#!/bin/bash
# platform = multi_platform_ubuntu

getent group "systemd-journal" &>/dev/null || groupadd systemd-journal

mkdir -p /run/log/journal
touch /run/log/journal/system.journal
chgrp nogroup /run/log/journal/system.journal
