#!/bin/bash
# remediation = none

mkdir /etc/rsyslog.d
cat >> /etc/rsyslog.d/test.conf <<EOF
action(type="omfwd"
       protocol="tcp"
       Target="remote.system.com"
       port="6514"
       StreamDriver="gtls"
       StreamDriverMode="1")
EOF
