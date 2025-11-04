#!/bin/bash
# packages = rsyslog
source setup.sh

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="x509/name" StreamDriverMode="1")' >> "$RSYSLOG_D_CONF"
