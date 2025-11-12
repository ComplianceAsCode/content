#!/bin/bash
# packages = rsyslog

{{{ setup_rsyslog_common() }}}
sed -i "/^\*\.\*.*/d" "$RSYSLOG_CONF"
