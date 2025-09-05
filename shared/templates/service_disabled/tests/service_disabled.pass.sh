#!/bin/bash
# packages = {{{ PACKAGENAME }}}

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" stop '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" disable '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" mask '{{{ DAEMONNAME }}}.service'
# Disable socket activation if we have a unit file for it
if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^{{{ DAEMONNAME }}}.socket'; then
    "$SYSTEMCTL_EXEC" stop '{{{ DAEMONNAME }}}.socket'
    "$SYSTEMCTL_EXEC" mask '{{{ DAEMONNAME }}}.socket'
fi
# The service may not be running because it has been started and failed,
# so let's reset the state so OVAL checks pass.
# Service should be 'inactive', not 'failed' after reboot though.
"$SYSTEMCTL_EXEC" reset-failed '{{{ DAEMONNAME }}}.service' || true
