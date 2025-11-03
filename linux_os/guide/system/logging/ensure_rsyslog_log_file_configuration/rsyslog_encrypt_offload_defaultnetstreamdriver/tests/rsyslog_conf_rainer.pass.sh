#!/bin/bash
# packages = rsyslog
bash -x setup.sh
bash -x remove_encrypt_offload_configs.sh

RSYSLOG_CONF="/etc/rsyslog.conf"

remove_encrypt_offload_configs

echo 'global(DefaultNetstreamDriver="gtls" DefaultNetstreamDriverCAFile="/path/to/contrib/gnutls/ca.pem" DefaultNetstreamDriverCertFile="/path/to/contrib/gnutls/cert.pem" DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem")' > $RSYSLOG_CONF
