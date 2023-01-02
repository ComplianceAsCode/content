#!/bin/bash

if [ ! -d /etc/rsyslog.d/ ]; then
    mkdir /etc/rsyslog.d
fi

cat >> /etc/rsyslog.d/test.conf <<EOF
action(type="omfwd" protocol="tcp" Target="remote.system.com" port="6514" StreamDriver="gtls" StreamDriverMode="1" StreamDriverAuthMode="x509/name" streamdriver.CheckExtendedKeyPurpose="on")
EOF
