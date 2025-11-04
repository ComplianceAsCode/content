#!/bin/bash
# packages = rsyslog
source setup.sh

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="0")' >> "$RSYSLOG_CONF"
