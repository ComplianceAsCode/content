#!/bin/bash
# packages = systemd

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" stop 'systemd-journald.socket'
"$SYSTEMCTL_EXEC" stop 'systemd-journald-dev-log.socket'
"$SYSTEMCTL_EXEC" stop 'systemd-journald.service'
"$SYSTEMCTL_EXEC" disable 'systemd-journald.service'
