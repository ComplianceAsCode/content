#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_defaultnetstreamdriver() }}}

echo 'global(DefaultNetstreamDriver="gtls" DefaultNetstreamDriverCAFile="/path/to/contrib/gnutls/ca.pem" DefaultNetstreamDriverCertFile="/path/to/contrib/gnutls/cert.pem" DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem")' > $RSYSLOG_CONF
