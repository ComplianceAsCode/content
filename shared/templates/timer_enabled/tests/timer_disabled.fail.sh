#!/bin/bash
# packages = {{{ PACKAGENAME }}}

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" stop '{{{ TIMERNAME }}}.timer'
"$SYSTEMCTL_EXEC" disable '{{{ TIMERNAME }}}.timer'
