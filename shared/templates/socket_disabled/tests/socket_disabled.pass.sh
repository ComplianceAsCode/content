#!/bin/bash

SOCKET_NAME="{{{ SOCKETNAME }}}.socket"
SYSTEMCTL_EXEC='/usr/bin/systemctl'

if "$SYSTEMCTL_EXEC" -q list-unit-files "$SOCKET_NAME"; then
    "$SYSTEMCTL_EXEC" stop "$SOCKET_NAME"
    "$SYSTEMCTL_EXEC" mask "$SOCKET_NAME"
fi
