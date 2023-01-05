#!/bin/bash
# packages = {{{ PACKAGENAME }}}

SYSTEMCTL_EXEC='/usr/bin/systemctl'
# Some services use <name>@.service style that is not meant to be activated at all,
# and only used via socket activation.
if "$SYSTEMCTL_EXEC" -q list-unit-files '{{{ DAEMONNAME }}}.service'; then
    "$SYSTEMCTL_EXEC" unmask '{{{ DAEMONNAME }}}.service'
    "$SYSTEMCTL_EXEC" start '{{{ DAEMONNAME }}}.service'
    "$SYSTEMCTL_EXEC" enable '{{{ DAEMONNAME }}}.service'
fi
# Enable socket activation if we have a unit file for it
if "$SYSTEMCTL_EXEC" -q list-unit-files '{{{ DAEMONNAME }}}.socket'; then
    "$SYSTEMCTL_EXEC" unmask '{{{ DAEMONNAME }}}.socket'
    "$SYSTEMCTL_EXEC" start '{{{ DAEMONNAME }}}.socket'
fi

# The service may not be running because it has been started and failed,
# so let's reset the state so OVAL checks pass.
# Service should be 'inactive', not 'failed' after reboot though.
"$SYSTEMCTL_EXEC" reset-failed '{{{ DAEMONNAME }}}.service' || true
