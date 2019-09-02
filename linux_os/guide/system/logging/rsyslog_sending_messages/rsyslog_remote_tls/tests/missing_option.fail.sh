#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

cat >> /etc/rsyslog.conf <<EOF
action(type="omfwd"
       protocol="tcp"
       Target="remote.system.com"
       port="6514"
       StreamDriver="gtls"
       StreamDriverMode="1")
EOF
