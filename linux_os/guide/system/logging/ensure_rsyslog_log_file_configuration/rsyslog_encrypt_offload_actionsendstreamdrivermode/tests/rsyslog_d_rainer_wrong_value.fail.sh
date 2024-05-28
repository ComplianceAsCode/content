#!/bin/bash
bash -x setup.sh

RSYSLOG_D_TEST_CONF='/etc/rsyslog.d/test.conf'

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="0" StreamDriverMode="42")' >> "$RSYSLOG_D_TEST_CONF"
