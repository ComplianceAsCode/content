#!/bin/bash
# packages = rsyslog
source setup.sh

cat << EOF >> "$RSYSLOG_CONF"
action(
    type="omfwd" 
    Target="some.example.com"
    StreamDriverAuthMode="0"
    StreamDriverMode="42"
)
EOF
