#!/bin/bash
# packages = rsyslog
source setup.sh

echo 'global(DefaultNetstreamDriver="tftp" DefaultNetstreamDriverKeyFile="/path/to/contrib/gnutls/key.pem")' > $RSYSLOG_D_CONF
