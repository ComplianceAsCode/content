#!/bin/bash

{{{ setup_rsyslog_remote_tls() }}}

cat >> $RSYSLOG_CONF <<EOF
action(type="omfwd"
       protocol="tcp"
       Target="remote.system.com"
       port="6514"
       StreamDriver="ossl"
       StreamDriverMode="1"
       StreamDriverAuthMode="x509/name"
       tls="off")
EOF
