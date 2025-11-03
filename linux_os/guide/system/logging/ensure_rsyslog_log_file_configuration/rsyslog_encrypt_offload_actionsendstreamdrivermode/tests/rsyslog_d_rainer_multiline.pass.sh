#!/bin/bash
# packages = rsyslog
bash -x setup.sh
bash -x remove_encrypt_offload_configs.sh

RSYSLOG_D_FOLDER='/etc/rsyslog.d'
RSYSLOG_D_TEST_CONF=$RSYSLOG_D_FOLDER'/test.conf'

touch $RSYSLOG_D_TEST_CONF

remove_encrypt_offload_configs

cat << EOF >> "$RSYSLOG_D_TEST_CONF"
action(
    type="omfwd"
    Target="some.example.com"
    StreamDriverAuthMode="x509/name"
    StreamDriverMode="1"
)
EOF
