#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_defaultnetstreamdriver() }}}

cat << EOF >> "$RSYSLOG_CONF"
global(
    DefaultNetstreamDriver="tftp"
    DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem"
)
EOF
