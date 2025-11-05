#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_defaultnetstreamdriver() }}}

cat << EOF >> "$RSYSLOG_CONF"
global(
    DefaultNetstreamDriver="gtls"
    DefaultNetstreamDriverCAFile="/path/to/contrib/gnutls/ca.pem"
    DefaultNetstreamDriverCertFile="/path/to/contrib/gnutls/cert.pem"
    DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem"
)
EOF
