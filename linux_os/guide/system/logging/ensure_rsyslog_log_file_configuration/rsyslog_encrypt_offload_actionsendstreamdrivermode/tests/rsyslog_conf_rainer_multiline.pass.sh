#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdrivermode() }}}

cat << EOF >> "$RSYSLOG_CONF"
action(
    type="omfwd"
    Target="some.example.com"
    StreamDriverAuthMode="x509/name"
    StreamDriverMode="1"
)
EOF
