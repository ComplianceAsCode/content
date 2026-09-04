# platform = multi_platform_ubuntu
# reboot = false
# strategy = disable
# complexity = low
# disruption = low

SYSTEMCTL_EXEC=/usr/bin/systemctl
if [[ $("$SYSTEMCTL_EXEC" is-system-running) != "offline" ]]; then
    "$SYSTEMCTL_EXEC" stop update-notifier-motd.service
fi
"$SYSTEMCTL_EXEC" disable update-notifier-motd.service
"$SYSTEMCTL_EXEC" mask update-notifier-motd.service
"$SYSTEMCTL_EXEC" reset-failed update-notifier-motd.service || true
