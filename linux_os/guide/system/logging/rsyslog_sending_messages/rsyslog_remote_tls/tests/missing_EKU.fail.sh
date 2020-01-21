#!/bin/bash
# remediation = none

cat >> /etc/rsyslog.conf <<EOF
action(type="omfwd"
       protocol="tcp"
       Target="remote.system.com"
       port="6514"
       StreamDriver="gtls"
       StreamDriverMode="1"
       StreamDriverAuthMode="x509/name")
EOF
