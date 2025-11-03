#!/bin/bash
# packages = rsyslog
bash -x setup.sh
bash -x remove_encrypt_offload_configs.sh

RSYSLOG_CONF='/etc/rsyslog.conf'

remove_encrypt_offload_configs

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="x509/name" StreamDriverMode="1")' >> "$RSYSLOG_CONF"
