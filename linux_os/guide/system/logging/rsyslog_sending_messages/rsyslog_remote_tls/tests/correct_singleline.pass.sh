#!/bin/bash

{{{ setup_rsyslog_remote_tls() }}}

cat >> $RSYSLOG_CONF <<EOF
action(type="omfwd" Target="remote.system.com" port="6514" StreamDriver="gtls" StreamDriverMode="1" StreamDriverAuthMode="x509/name" streamdriver.CheckExtendedKeyPurpose="on" protocol="tcp")
EOF
