#!/bin/bash
# packages = systemd-journal-remote

SOCKET_NAME="systemd-journal-remote.socket"
SYSTEMCTL_EXEC='/usr/bin/systemctl'

if "$SYSTEMCTL_EXEC" -q list-unit-files "$SOCKET_NAME"; then
    "$SYSTEMCTL_EXEC" unmask "$SOCKET_NAME"
    "$SYSTEMCTL_EXEC" start "$SOCKET_NAME"
fi
