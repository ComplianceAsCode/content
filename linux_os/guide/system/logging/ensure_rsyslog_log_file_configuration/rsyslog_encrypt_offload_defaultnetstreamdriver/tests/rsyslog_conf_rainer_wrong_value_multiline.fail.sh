#!/bin/bash
# packages = rsyslog
bash -x setup.sh
bash -x remove_encrypt_offload_configs.sh

RSYSLOG_CONF="/etc/rsyslog.conf"

remove_encrypt_offload_configs

cat << EOF >> "$RSYSLOG_CONF"
global(
    DefaultNetstreamDriver="tftp"
    DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem"
)
EOF
