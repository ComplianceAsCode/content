#!/bin/bash
bash -x setup.sh

RSYSLOG_CONF='/etc/rsyslog.conf'

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="0")' >> "$RSYSLOG_CONF"
