#!/bin/bash

RSYSLOG_CONF='/etc/rsyslog.conf'

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="0" StreamDriverMode="42")' >> "$RSYSLOG_CONF"
