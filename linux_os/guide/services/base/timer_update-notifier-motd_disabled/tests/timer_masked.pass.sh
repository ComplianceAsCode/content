#!/bin/bash
# packages = update-notifier-common

SYSTEMCTL_EXEC='/usr/bin/systemctl'
if "$SYSTEMCTL_EXEC" -q list-unit-files 'update-notifier-motd.timer'; then
    "$SYSTEMCTL_EXEC" stop 'update-notifier-motd.timer'
    "$SYSTEMCTL_EXEC" disable 'update-notifier-motd.timer'
    "$SYSTEMCTL_EXEC" mask 'update-notifier-motd.timer'
fi
"$SYSTEMCTL_EXEC" reset-failed 'update-notifier-motd.timer' || true
