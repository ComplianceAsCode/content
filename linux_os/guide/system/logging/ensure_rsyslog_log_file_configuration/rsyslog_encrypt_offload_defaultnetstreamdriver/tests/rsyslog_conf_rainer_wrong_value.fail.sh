#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_defaultnetstreamdriver() }}}

echo 'global(DefaultNetstreamDriver="tftp" DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem")' > $RSYSLOG_CONF
