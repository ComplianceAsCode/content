#!/bin/bash
# packages = update-notifier-common

SYSTEMCTL_EXEC='/usr/bin/systemctl'
if "$SYSTEMCTL_EXEC" -q list-unit-files 'update-notifier-motd.service'; then
    "$SYSTEMCTL_EXEC" stop 'update-notifier-motd.service'
    "$SYSTEMCTL_EXEC" mask 'update-notifier-motd.service'
fi
"$SYSTEMCTL_EXEC" reset-failed 'update-notifier-motd.service' || true
