#!/bin/bash
# variables = rsyslog_remote_loghost_address=remote.system.com

{{{ setup_rsyslog_remote_tls() }}}

cat >> $RSYSLOG_CONF <<EOF
action(type="omfwd"
       protocol="tcp"
       Target="remote.system.com"
       port="6514"
       StreamDriver="ossl"
       StreamDriverMode="1"
       tls.authmode="x509/name"
       tls.permittedpeer="remote.system.com"
       tls="on")
EOF
