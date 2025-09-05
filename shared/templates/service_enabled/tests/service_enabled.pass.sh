#!/bin/bash
# packages = {{{ PACKAGENAME }}}

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" unmask '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" start '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" enable '{{{ DAEMONNAME }}}.service'
