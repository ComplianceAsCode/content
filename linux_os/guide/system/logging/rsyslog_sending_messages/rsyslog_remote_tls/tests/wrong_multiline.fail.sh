#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

cat >> /etc/rsyslog.conf <<EOF
action(type="omfwd"
       protocol="tcp"
       Target="remote.system.com"
       port="6514"
       StreamDriver="ptcp"
       StreamDriverMode="1"
       StreamDriverAuthMode="x509/name")
EOF
