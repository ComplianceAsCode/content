#!/bin/bash
# packages = rsyslog
source setup.sh

cat << EOF >> "$RSYSLOG_CONF"
action(
    type="omfwd"
    Target="some.example.com"
    StreamDriverAuthMode="x509/name"
    StreamDriverMode="1"
)
EOF
