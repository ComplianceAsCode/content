#!/bin/bash
# packages = rsyslog
source setup.sh

cat << EOF >> "$RSYSLOG_CONF"
global(
    DefaultNetstreamDriver="tftp"
    DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem"
)
EOF
