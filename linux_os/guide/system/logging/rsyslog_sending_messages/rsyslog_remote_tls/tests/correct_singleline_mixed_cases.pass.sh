#!/bin/bash

{{{ setup_rsyslog_remote_tls() }}}

cat >> $RSYSLOG_CONF <<EOF
action(tYpe="omfwd" protocol="tcp" TarGet="remote.system.com" port="6514" StreaMDrIver="gtls" StrEamDriverMode="1" StreamDrivErAuthMode="x509/name" stReamDriver.CheckExteNdedKeyPurpose="on")
EOF
