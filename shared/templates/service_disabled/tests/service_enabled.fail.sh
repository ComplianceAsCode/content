#!/bin/bash
# packages = {{{ PACKAGENAME }}}

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" unmask '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" start '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" enable '{{{ DAEMONNAME }}}.service'

# The service may not be running because it has been started and failed,
# so let's reset the state so OVAL checks pass.
# Service should be 'inactive', not 'failed' after reboot though.
"$SYSTEMCTL_EXEC" reset-failed '{{{ DAEMONNAME }}}.service' || true
