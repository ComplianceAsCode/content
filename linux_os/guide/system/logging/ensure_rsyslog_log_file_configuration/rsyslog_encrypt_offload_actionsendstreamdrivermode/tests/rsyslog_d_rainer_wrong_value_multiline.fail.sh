#!/bin/bash
# packages = rsyslog
bash -x setup.sh
bash -x remove_encrypt_offload_configs.sh

RSYSLOG_D_TEST_CONF='/etc/rsyslog.d/test.conf'

remove_encrypt_offload_configs

cat << EOF >> "$RSYSLOG_D_TEST_CONF"
action(
    type="omfwd"
    Target="some.example.com"
    StreamDriverAuthMode="0"
    StreamDriverMode="42"
)
EOF
