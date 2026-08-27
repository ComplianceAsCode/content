#!/bin/bash
# platform = multi_platform_ubuntu

getent group "systemd-journal" &>/dev/null || groupadd systemd-journal

mkdir -p /run/log/journal /var/log/journal
chgrp systemd-journal /run/log/journal /var/log/journal
