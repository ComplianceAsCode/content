#!/bin/bash
# packages = rsyslog
source setup.sh

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="0" StreamDriverMode="42")' >> "$RSYSLOG_D_CONF"
