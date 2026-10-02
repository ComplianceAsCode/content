# platform = multi_platform_ubuntu
# reboot = false
# strategy = disable
# complexity = low
# disruption = low

SYSTEMCTL_EXEC=/usr/bin/systemctl
unit=update-notifier-motd.timer
if "$SYSTEMCTL_EXEC" list-unit-files "$unit" --no-legend 2>/dev/null | grep -q "^${unit}[[:space:]]"; then
    if [[ $("$SYSTEMCTL_EXEC" is-system-running) != "offline" ]]; then
        "$SYSTEMCTL_EXEC" stop "$unit"
    fi
    "$SYSTEMCTL_EXEC" disable "$unit"
    "$SYSTEMCTL_EXEC" mask "$unit"
    "$SYSTEMCTL_EXEC" reset-failed "$unit" || true
fi
