#!/bin/bash

{{{ setup_rsyslog_remote_tls() }}}

cat >> $RSYSLOG_D_CONF <<EOF
action(type="omfwd"
       protocol="tcp"
       Target="remote.system.com"
       port="6514"
       StreamDriverMode="1"
       tls="on")
EOF
