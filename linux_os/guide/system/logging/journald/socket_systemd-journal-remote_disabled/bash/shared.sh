# platform = multi_platform_ubuntu

SOCKET_NAME="systemd-journal-remote.socket"
SYSTEMCTL_EXEC='/usr/bin/systemctl'

if "$SYSTEMCTL_EXEC" -q list-unit-files "$SOCKET_NAME"; then
    "$SYSTEMCTL_EXEC" stop "$SOCKET_NAME"
    "$SYSTEMCTL_EXEC" unmask "$SOCKET_NAME"
fi
