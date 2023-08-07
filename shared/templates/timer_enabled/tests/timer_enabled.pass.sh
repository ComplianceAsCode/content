#!/bin/bash
# packages = {{{ PACKAGENAME }}}

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" unmask '{{{ TIMERNAME }}}.timer'
"$SYSTEMCTL_EXEC" start '{{{ TIMERNAME }}}.timer'
"$SYSTEMCTL_EXEC" enable '{{{ TIMERNAME }}}.timer'
