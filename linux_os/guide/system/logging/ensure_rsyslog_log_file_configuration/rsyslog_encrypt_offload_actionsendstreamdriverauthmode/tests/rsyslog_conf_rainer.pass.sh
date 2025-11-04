#!/bin/bash
# packages = rsyslog
source setup.sh

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="x509/name")' >> "$RSYSLOG_CONF"
