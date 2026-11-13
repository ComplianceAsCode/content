#!/bin/bash
# packages = update-notifier-common

SYSTEMCTL_EXEC='/usr/bin/systemctl'
if "$SYSTEMCTL_EXEC" -q list-unit-files 'update-notifier-motd.timer'; then
    "$SYSTEMCTL_EXEC" unmask 'update-notifier-motd.timer'
    "$SYSTEMCTL_EXEC" enable 'update-notifier-motd.timer'
    "$SYSTEMCTL_EXEC" start 'update-notifier-motd.timer'
fi
