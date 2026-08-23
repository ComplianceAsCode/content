#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdrivermode() }}}

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="0" StreamDriverMode="42")' >> "$RSYSLOG_D_CONF"
